# Backend API Structure (unified-route pattern)

เอกสารนี้คือ reference ของ "จัดโครง backend API อย่างไร" — คู่ของ `frontend-structure.md` แต่ฝั่ง server
เปิดอ่านทุกครั้งที่จะเพิ่ม domain/endpoint ใหม่ หรือสงสัยว่าไฟล์แต่ละตัวมีหน้าที่อะไร

> TL;DR — 1 endpoint = vertical slice ผ่าน 5 ชั้น: **core** (สัญญา/contract) → **service** (logic) → **client** (ตัวเรียก) → **data** (prisma) → **app** (route). แต่ละชั้นแยก dependency ชัด, ฉีดของผ่าน DI registry, คืนค่าเป็น `ResultV2`, ห่อด้วย telemetry

---

## 1. ภาพรวม 5 ชั้น

```
libs/<scope>/shared-api/
  core/      @<ws>/shared-api-core      — contract: repository interface + types + DI keys (ไม่มี logic, ไม่แตะ DB)
  service/   @<ws>/shared-api-service   — logic: validate + ขั้นตอน (pre-handlers/handler) + endpoint
  client/    @<ws>/shared-api-client    — ตัวเรียก API ฝั่ง consumer (typed fn + client class)
libs/<scope>/<data>/store-prisma         @<ws>/<data>-store-prisma — data: implement repository ด้วย prisma
apps/<webapi>/mcs-fastify                — app: route (composition root) + telemetry plugin
```

หลักการ: **core ไม่รู้จัก prisma, service ไม่รู้จัก fastify, client ไม่รู้จัก server** — แต่ละชั้นพึ่งแค่ "สัญญา" ของชั้นที่ต่ำกว่า ทำให้เปลี่ยน DB / framework / transport ได้โดยไม่กระทบ logic

---

## 2. โครง src ของ 1 domain (เช่น `product-api`)

domain = กลุ่ม endpoint ที่อยู่ด้วยกัน (เช่น product-api มี create-product, get-product, ...) วางเป็น subfolder ใน shared-api:

```
core/src/product-api/
  registry.const.ts                       # DI keys (REPO_CREATE_PRODUCT, ...)
  index.ts                                # export registry
  command/create-product/
    repository/type.ts                    # Input/Output types
    repository/repository.ts              # interface Repository (สัญญา ฉีดผ่าน DI)
    repository/index.ts
    index.ts
  query/get-product/ ...                  # โครงเดียวกัน

service/src/product-api/
  command/create-product/
    dto.ts                                # zod schema (validate ที่ขอบ)
    logic/business.logic.ts               # pure logic (validate/transform) — test ตรงๆ
    logic/routeSteps.logic.ts             # pre-handlers/handler (I/O, registry, repo) + setupProcess (wiring)
    logic/__tests__/...                   # unit tests (1 ไฟล์/action)
    endpoint/endpoint.config.ts           # makeTelemetryEndpoint(setupProcess)
    index.ts
  query/get-product/ ...

client/src/product-api/
  types.ts                                # CustomHeader
  command/create-product/{types,endpoint,index}.ts   # Request/Response + fn เรียก API
  query/get-product/ ...
  client.ts                               # ProductClient (รวม fn ของ domain)
  index.ts
```

ฝั่ง data + app (wire):
```
<data>/store-prisma/src/product-factory/
  command/create-product/repository.ts    # class CreateProductRepo implements core Repository (ใช้ prisma)
  query/get-product/repository.ts
<data>/store-prisma/prisma/schema.prisma   # model Product { ... }
apps/<webapi>/mcs-fastify/src/routes/product-api/
  create-product/index.ts                 # fastify route: ฉีด repo เข้า registry แล้วเรียก endpoint
  get-product/index.ts
```

---

## 3. หน้าที่แต่ละไฟล์ (สำคัญ)

| ไฟล์ | ชั้น | หน้าที่ | กฎ |
|---|---|---|---|
| `registry.const.ts` | core | ประกาศ DI key (string) ของ repository แต่ละตัว | ค่าคงที่ ไม่มี logic |
| `repository/repository.ts` | core | `interface Repository` = สัญญาว่ามี method อะไร คืน `Result<T, BaseFailure>` | **interface เท่านั้น** ตัวจริงอยู่ data layer |
| `repository/type.ts` | core | Input/Output types ของ repo | type ล้วน |
| `dto.ts` | service | zod schema + `z.infer` type | validate ที่ขอบ request |
| `business.logic.ts` | service | **pure logic** (validate rule, transform) | ไม่มี I/O / ไม่แตะ context/registry → test ง่าย, reuse ได้ |
| `routeSteps.logic.ts` | service | pre-handlers + handler (อ่าน registry, เรียก repo, คืน `ResultV2`) + `setupProcess()` (ลำดับ pre-handlers) | logic ที่มี side-effect อยู่ที่นี่ |
| `endpoint/endpoint.config.ts` | service | `makeTelemetryEndpoint(setupProcess)` → route handler ห่อ telemetry | บางสุด |
| `client/.../endpoint.ts` | client | fn เรียก API (`inhClient.post(...)`) คืน typed `DataResponse` | จับ error คืน response แบบ fail |
| `client/.../client.ts` | client | class รวม fn ของ domain (`ProductClient`) | convenience |
| `store-prisma/.../repository.ts` | data | `class XxxRepo implements Repository` ใช้ prisma | try/catch → `Result.ok/fail` |
| `routes/.../index.ts` | app | composition root: `new XxxRepo(prisma)` → `addRegistryItem(ctx, KEY, repo)` → เรียก endpoint | ฉีด dependency ที่นี่ |

---

## 4. Request flow (ต่อ 1 request)

```
fastify route (composition root)
  └─ ฉีด repo เข้า DI registry (addRegistryItem)
  └─ createUnifiedFastifyHandler(endpoint)
        └─ makeTelemetryEndpoint(setupProcess)         # ห่อ telemetry pipeline
              ├─ preHandlers (เรียงลำดับ):
              │    authGuard           # ตรวจสิทธิ์ (demo = stub; จริงเสียบ jwt/permission)
              │    mapReqToInput        # map body -> DTO -> validate (zod)
              │    processCheckRequired # validate business rule (เรียก business.logic)
              │    processCheckDuplicate# เรียก repo เช็คซ้ำ
              └─ handler:
                   processCreateInRepo  # เรียก repo สร้างจริง -> ResultV2.toHttpResponse
```

ทุก pre-handler/handler ดึง **telemetry** (logger+traceId) และ **repo** ออกจาก registry ด้วย `getRegistryItem(ctx, KEY)` — ของพวกนี้ถูกฉีดเข้ามาตอน composition root + telemetry plugin

---

## 5. แนวคิดหลัก 3 อย่าง

**DI registry** — ของที่ขึ้นกับ runtime (repo, telemetry service) ไม่ถูก import ตรงๆ แต่ฉีดเข้า `ctx.registry` ตอน route แล้ว logic ดึงด้วย key → service ไม่ผูกกับ prisma/fastify, test ง่าย (mock registry)

**ResultV2** (`@inh-lib/common`) — แทน throw ด้วยค่าที่บอกสำเร็จ/ล้มเหลว: `Result.ok(v)` / `Result.fail(new CommonFailures.XxxFail(...))`, มี `.isFailure`, `.getValue()`, `.withTraceId()`, `.toHttpResponse(res)` — error เป็น `BaseFailure` (ไม่ใช่ Error ธรรมดา) เพื่อ map เป็น http status ได้

**telemetry** (`@inh-lib/unified-telemetry-*`) — ทุก endpoint ห่อด้วย pipeline ที่สร้าง span + logger พร้อม traceId อัตโนมัติ; demo ใช้ Console provider, production สลับเป็น OTEL exporter ผ่าน `.env` (ดู `docs` telemetry / app `create-telemetry.ts`)

**auth-guard = "ช่อง" (slot)** — `authGuardPreHandler` ใน base เป็น stub (เช็ค header เฉยๆ) ของจริงในองค์กร (jwt-auth / module-permission / check-endpoint / S3) ให้ทำเป็น **private overlay** แล้วเสียบแทนใน `setupProcess().preHandlers` — public template ไม่มีโค้ดเฉพาะองค์กร

---

## 6. 2 รูปแบบโครงสร้าง: grouped vs promoted

เหมือนฝั่ง frontend (folder ใน lib ↔ promoted เป็น project) — domain มี 2 รูปแบบ:

| | **grouped** (ค่าเริ่มต้น) | **promoted** (standalone) |
|---|---|---|
| package | `@<ws>/shared-api-core` | `@<ws>/product-api-core` |
| src | `src/product-api/command/...` (มี domain wrapper) | `src/command/...` (ไม่มี wrapper) |
| exports | `./product-api/command/*` | `./command/*` |
| import | `@<ws>/shared-api-core/product-api/command/...` | `@<ws>/product-api-core/command/...` |
| ใช้เมื่อ | ปกติ — หลาย domain อยู่รวมใน shared-api | domain ใหญ่/มี consumer แยก/build แยกเพื่อกัน OOM |

**เมื่อไรควร promote:** domain ถูกใช้โดย consumer ตัวที่ 2 หรือ build รวมแล้วหน่วยความจำไม่พอ (เหมือนเกณฑ์ promote ฝั่ง frontend) — ดูวิธี promote ใน `api-scaffolding.developer-guide.md`

> `gen:api-domain` สร้างแบบ **grouped**; แปลงไป-กลับระหว่าง grouped ↔ standalone อัตโนมัติด้วย **`pnpm gen:api-promote`** (grouped→standalone) และ **`pnpm gen:api-demote`** (standalone→grouped) — ดู user-guide

---

## 7. naming convention

- repo: `<corp|product>-<system>-system` → scope = `@<corp>-<system>` (เช่น `demo-shop-system`)
- api package: `shared-api` → `@<ws>/shared-api-{core,service,client}`
- domain (subfolder): `<name>-api` (เช่น `product-api`, `order-api`)
- action: `command/<verb>-<name>` หรือ `query/<verb>-<name>` (เช่น `create-product`, `get-product`)
- DI key const: `<DOMAINUP>_API_CONTEXT_KEY.REPO_<ACTION>`
- data factory: `<domain>-factory/command|query/<action>/repository.ts`

---

## ดูต่อ

- วิธีใช้งานจริง (สร้าง API ตั้งแต่ศูนย์) → `docs/api-scaffolding.user-guide.md`
- วิธีแก้ template/scaffolding (สำหรับ maintainer) → `docs/api-scaffolding.developer-guide.md`
- export/build strategy → `docs/export-strategy.md`
- ทำไม template ดูเยอะ → `docs/why-this-architecture.md`
