# API Scaffolding — User Guide (เพิ่ม backend API ตั้งแต่ศูนย์)

คู่มือใช้งานแบบทำตามได้เลย เน้น copy–paste เข้าใจโครงลึกๆ ดูที่ `backend-structure.md`

> รันคำสั่ง `pnpm ...` ทั้งหมด **จากในโฟลเดอร์ `workspaces/node-app`** (pnpm workspace root)
> และต้อง clone `workspace-generator` ไว้ระดับเดียวกับโฟลเดอร์ workspace ของคุณ (หรือ set `WORKSPACE_GENERATOR_DIR`)

> ℹ️ **workspace-generator จำเป็นเฉพาะตอน "สร้างของใหม่" (`pnpm gen:api-*`) เท่านั้น**
> งานประจำวัน — `pnpm lint` / `test` / `build` / `make test` / รัน app — **workspace ทำเองได้ครบ ไม่ต้องมี generator** (โค้ดที่ gen ออกมาแล้ว self-contained); ถ้าลบ generator ไป build/run ยังทำงานปกติ แค่ `pnpm gen:api-*` จะใช้ไม่ได้จนกว่าจะ clone กลับมา
> 🔄 **อัปเดต scaffolding = `git pull` ที่ `workspace-generator` ที่เดียว** → ทุก workspace ที่ชี้มาได้ของใหม่ทันที (ไม่ต้องตามแก้ทีละ workspace)

---

## TL;DR — เพิ่ม 1 API ใน 4 ขั้น

```bash
# 1) สร้าง slice ของ domain (core+service+client) — เช่น domain "order"
pnpm gen:api-domain shared-webapi shared-api order

# 2) wire ลง DB + endpoint (prisma repo + fastify route + prisma model)
#    + สร้าง contract⇄backend-test pair ให้อัตโนมัติ (opt-out: SKIP_CONTRACT=1)
pnpm gen:api-wire shared-webapi shared-api demo-shop-data demo-shop-webapi order

# 3) แก้ field/logic/model ให้ตรงงานจริง (ดูข้อ "แก้อะไรบ้าง" ด้านล่าง)

# 4) generate prisma client + migration + ทดสอบ
cd libs/shared-webapi/demo-shop-data/store-prisma
pnpm prisma:generate
pnpm gen:up-script            # สร้าง migration (ต้องมี DATABASE_URL ใน .env)
cd ../../../../ && make test  # ทดสอบ backend ทั้งหมดใน docker (ถ้ามี Makefile)
```

ผลที่ได้: endpoint `POST /<prefix>/order-api/create-order` และ `GET /<prefix>/order-api/get-order/:id` พร้อม validate + telemetry + DI ครบ

---

## ก่อนเริ่ม: ต้องมี base package ก่อน

ถ้ายังไม่มี shared-api / store-prisma / webapi ใน workspace ให้สร้าง base ก่อน (ทำครั้งเดียว) — รันจาก **dir แม่** ที่มี workspace + generator เป็น sibling:

```bash
bash workspace-generator/script-generator/new-apicore.sh    <workspace> shared-api shared-webapi
bash workspace-generator/script-generator/new-apiservice.sh <workspace> shared-api shared-webapi
bash workspace-generator/script-generator/new-apiclient.sh  <workspace> shared-api shared-webapi
bash workspace-generator/script-generator/new-storeprisma.sh <workspace> demo-shop-data
bash workspace-generator/script-generator/new-webapi.sh      <workspace> demo-shop-webapi
```

base ที่ได้สะอาด (ไม่มีตัวอย่าง bible เก่า) + พร้อมรับ scaffolding ทันที

---

## คำสั่ง scaffolding

> 💡 **ไม่ใส่ param ก็ได้** — รัน `pnpm gen:api-domain` เฉยๆ แล้วมันจะ **ถามทีละค่า** (TUI) ให้กรอก
> 💡 **เลือก gen เฉพาะชั้น** — `gen:api-domain` / `gen:api-action` รับ `[layer]` ท้ายสุด (`core|service|client|all`, default `all`) เช่น `pnpm gen:api-domain shared-webapi shared-api order core`

### แปลงโครง grouped ↔ standalone (promote / demote)
```bash
# grouped domain (ใน shared-api) -> standalone project (<domain>-api แยก, src แบน)
pnpm gen:api-promote <scope> <shared-api> <domain>
#   เช่น: pnpm gen:api-promote shared-webapi shared-api product

# standalone project -> grouped domain (กลับเข้า shared-api)
pnpm gen:api-demote <scope> <project> <shared-api>
#   เช่น: pnpm gen:api-demote shared-webapi product-api shared-api
```
> แก้ import + deps + exports ของทั้ง workspace ให้อัตโนมัติ (ตรวจ `git diff` ได้); ถ้ามี root aggregate client (custom) ต้องแก้เอง

### `pnpm gen:api-domain <scope> <api-pkg> <domain> [layer]`
สร้าง vertical slice ของ domain (command `create-<domain>` + query `get-<domain>`) ครบ **core/service/client** + อัปเดต exports + core index ให้อัตโนมัติ

```bash
pnpm gen:api-domain shared-webapi shared-api order
#                   │            │          └ domain (ลงท้ายไม่ต้องมี -api)
#                   │            └ api package folder
#                   └ group folder ใต้ libs/
```

### `pnpm gen:api-wire <scope> <api-pkg> <data-pkg> <webapi-app> <domain>`
ต่อ domain เข้ากับฐานข้อมูล + endpoint จริง: gen **prisma repo + fastify route + prisma model** + ใส่ deps ที่ webapi

```bash
pnpm gen:api-wire shared-webapi shared-api demo-shop-data demo-shop-webapi order
#                                          │              └ webapi app folder
#                                          └ data package folder (มี store-prisma)
```

> ทำ `gen:api-domain` ก่อนเสมอ แล้วค่อย `gen:api-wire`

---

## ตัวอย่างผลลัพธ์จริง (รัน `order` ให้ดู)

### `pnpm gen:api-domain shared-webapi shared-api order`

**ที่ขึ้นบน terminal:**
```
scaffold domain 'order-api' (Domain=Order UPPER=ORDER) into demo-shop-system/.../shared-api/{core,service,client}
  + core/src/order-api
  + service/src/order-api
  + client/src/order-api
done: domain order-api scaffolded. add a data-layer repo + webapi route to wire it.
```

**ไฟล์ที่ได้** (เกิดใน 3 package):
```
core/src/order-api/
├── registry.const.ts                 # ORDER_API_CONTEXT_KEY
├── index.ts
├── __test__/registry.test.ts
├── command/create-order/
│   ├── contract.type.ts              # Repository interface + Input/Output types
│   └── index.ts
└── query/get-order/
    ├── contract.type.ts
    └── index.ts

service/src/order-api/
├── command/create-order/
│   ├── dto.ts
│   ├── endpoint/endpoint.config.ts
│   └── logic/{business.logic.ts, routeSteps.logic.ts, __tests__/...}
└── query/get-order/ ...

client/src/order-api/
├── client.ts                         # OrderClient
├── types.ts
├── command/create-order/{types.ts, endpoint.ts, index.ts}
└── query/get-order/ ...
```

**+ อัปเดตอัตโนมัติ:** `exports` ใน package.json ของ core/service/client (เพิ่ม `./order-api/command/*` ฯลฯ) และ `core/src/index.ts` (`export * from './order-api'`)

ตัวอย่างไฟล์ที่ gen ออกมา — `core/src/order-api/registry.const.ts`:
```ts
export const ORDER_API_CONTEXT_KEY = {
  REPO_CREATE_ORDER: 'OrderApi.Repository.CreateOrder',
  REPO_GET_ORDER: 'OrderApi.Repository.GetOrder',
} as const;
```

> ตอนนี้ `pnpm --filter @<ws>/shared-api-service test` ผ่าน (มี unit test create/get มาให้) — แต่ยังเรียกใช้งานจริงไม่ได้จนกว่าจะ wire

### `pnpm gen:api-wire shared-webapi shared-api demo-shop-data demo-shop-webapi order`

**ที่ขึ้นบน terminal:**
```
  + store-prisma/order-api/command/create-order
  + store-prisma/order-api/query/get-order
  + routes/order-api/create-order
  + routes/order-api/get-order
  + prisma model Order (run: pnpm prisma:generate && pnpm gen:up-script)
wired order: store-prisma repo + webapi route + prisma model. run prisma:generate + migration.
```

**ไฟล์ที่ได้:**
```
libs/shared-webapi/demo-shop-data/store-prisma/
├── src/order-api/command/create-order/   # Action-Based (CreateOrderEntry)
│   ├── entry.ts  createOrder.task.ts  checkDuplicateSku.task.ts  flows.ts
│   ├── db.logic.ts  data.logic.ts  internal.type.ts  index.ts
│   └── __tests__/createOrder.test.ts
├── src/order-api/query/get-order/         # entry.ts getOrder.task.ts db.logic.ts data.logic.ts internal.type.ts index.ts (+__tests__)
└── prisma/schema.prisma   ← model Order { ...fields + audit: createdBy/createdAt/updatedBy/updatedAt @map UPPER_SNAKE }

apps/demo-shop-webapi/mcs-fastify/src/routes/order-api/
├── create-order/index.ts   # POST route — ฉีด CreateOrderEntry เข้า registry แล้วเรียก endpoint
└── get-order/index.ts      # GET  route
```

**+ อัปเดตอัตโนมัติ:** `exports` ใน store-prisma + `dependencies` ใน webapi (shared-api-core/service, store-prisma)

**endpoint ที่ได้** (ใช้งานได้หลัง `prisma:generate` + migration):
```
POST /<API_PREFIX>/order-api/create-order      body: { name, sku, price, description? }
GET  /<API_PREFIX>/order-api/get-order/:id
```

---

## แก้อะไรบ้าง (หลัง gen)

scaffolding สร้างตัวอย่างที่มี field `name / sku / price / description` มาให้ — แก้ให้ตรงงานจริง:

1. **field ของข้อมูล** — `core/src/<domain>-api/command/create-<domain>/contract.type.ts`
   (Input/Output) และ `service/.../dto.ts` (zod schema) ให้ตรงกัน
2. **กฎ validate** — `service/.../logic/business.logic.ts` (ฟังก์ชัน `validateCreate<Domain>Input`)
3. **prisma model** — `<data>/store-prisma/prisma/schema.prisma` (model `<Domain>`) ให้ field ตรงกับ type
4. **client request/response** — `client/src/<domain>-api/command/.../types.ts`
5. (option) **auth** — ใน base ใช้ `authGuardPreHandler` แบบ stub; ถ้ามี auth จริงให้เสียบ pre-handler ของคุณใน `routeSteps.logic.ts` → `setupProcess().preHandlers`

> แก้ field ที่ type.ts/dto.ts/schema.prisma ให้ "ตรงกันทั้ง 3 ที่" คือจุดที่พลาดบ่อย

---

## เพิ่ม action อื่นในdomain เดิม (เช่น update-order)

`gen:api-domain` ให้ create + get มา; เพิ่ม action อื่นด้วย **`gen:api-action`**:

```bash
pnpm gen:api-action <scope> <api-pkg> <domain> <command|query> <verb>
#   เช่น: pnpm gen:api-action shared-webapi shared-api order command update
#         pnpm gen:api-action shared-webapi shared-api order query list
```
มันจะ gen action `<verb>-<domain>` ครบ core/service/client + เพิ่ม DI key ใน `registry.const.ts` ให้อัตโนมัติ (exports ใช้ wildcard `command/*` อยู่แล้ว จึงไม่ต้องแก้)
> action ที่ได้เป็น "โครงเริ่มต้น" (command อิงแบบ create, query อิงแบบ get) — แก้ field/logic ให้ตรงงาน; ถ้าเป็น command ที่ต้องเขียน DB ก็เพิ่ม repo+route แบบเดียวกับ `gen:api-wire` (หรือ copy ตามของ create)

---

## Infrastructure + backend-test (api-test ระดับ API — black-box)

นอกจาก unit test (white-box, jest, co-located ใน node-app) generator ยัง scaffold **api-test**
(black-box, out-of-process, **`node:test`**) + **infrastructure** (contract SSOT / db / liquibase / docker-compose)
ให้ด้วย — ยิง HTTP เข้า service ที่รันจริง + DB จริง เทียบผลกับ **contract** (SSOT)

### one-time ต่อ system: `pnpm gen:infra <service> <db-schema> [scope] [data-pkg] [api-pkg]`
```bash
pnpm gen:infra demo-shop-webapi demo-shop
#              │                └ db-schema folder (kebab) → db/<db-schema>/ · schema name = UPPER
#              └ service = webapi app → contract/ + backend-test/ group ต่อ service
```
สร้าง: `workspaces/infrastructure/` (docker-compose + liquibase changelog[context migrate|init|seed ·
label domain:] + db/<db-schema>/{init,seed}/{shared,tenant} + contract/ SSOT root) ·
`workspaces/backend-test/` (harness node:test + `_conformance/` skeleton) · **root `Makefile`** +
`.gitattributes`/`.editorconfig` (LF/TAB)

### ต่อ action: contract⇄test **คู่กัน** (gen:api-wire ทำให้อัตโนมัติแล้ว)
`gen:api-wire` เรียก `gen:api-contract` ให้เอง (create+get) · เพิ่ม action เดี่ยว/regenerate ใช้:
```bash
pnpm gen:api-contract <service> <domain> [action]
#   เช่น: pnpm gen:api-contract demo-shop-webapi product update-product
#         pnpm gen:api-contract demo-shop-webapi product            # ว่าง = create+get
```
ได้ **คู่กัน**: `infrastructure/contract/<service>/<domain>-api/<action>/`
(`c1/e1.json` envelope + `setup/teardown.sql` + `_cases.json`) **+**
`backend-test/<service>/<domain>-api/<action>.test.ts` (วน `_cases.json`) · และ (ครั้งเดียว/domain)
`db/<db-schema>/seed/<domain>-api/base.sql` + liquibase changeSet (context=seed, label=domain:)

### รัน (bring-up สด → test → down · local == CI)
```bash
cd workspaces/backend-test && pnpm install   # ครั้งเดียว (backend-test = standalone package)
cd ../../ && make api-test                                          # ทุก domain
make api-test DOMAIN=product-api                                    # เฉพาะ domain
make api-test DOMAIN=product-api ACTION=create-product             # เฉพาะ action
```
> แก้ envelope (`body`/`headers`/`dataResult`) + `setup/teardown.sql` ให้ตรง action จริง ·
> `_conformance/` เติม type-check เทียบ core Input/Output (กัน contract drift)

> 📖 แนวคิด/ADR/strategy เต็ม (white-box vs black-box · contract SSOT · db scope ladder · make/compose/liquibase) →
> [Backend Test & Infrastructure](https://bebestdev.com/developer-handbook/backend-test-infrastructure.html) ·
> DB strategy (server/instance/schema + evolution S→M→L) →
> [DB Architecture Standard (ARCH-STD-001)](https://bebestdev.com/developer-handbook/db-architecture-standard.html)

---

## ทดสอบ (unit — white-box)

```bash
# รายตัว (จาก node-app) — รันได้โดยไม่ต้อง build dependency ก่อน (dev-condition exports)
cd libs/shared-webapi/shared-api/service && pnpm lint && pnpm test

# backend ทั้งหมด + prisma generate ใน container (ไม่ต้อง install อะไรลงเครื่อง)
make test
```

> `make test` ใช้ docker build รัน prisma v6 generate + lint/test/tsc ทุก package — เหมาะตอนอยากชัวร์ทั้งระบบ

---

## prisma v6 (สำคัญ)

- generator ใช้ **prisma v6** (`prisma-client` generator → ออก client ที่ `store-prisma/generated/client/`)
- ต้องรัน `pnpm prisma:generate` ก่อน lint/test ของ store-prisma + webapi (client ถูก gitignore — สร้างใหม่ทุกเครื่อง)
- ต้องการ network โหลด prisma engine (ถ้า offline จะ generate ไม่ได้)
- จะกลับไป v5: เปิด comment ชุด v5 ใน `schema.prisma` + เปลี่ยน `build` เป็น `build:prisma`

---

## ปัญหาที่เจอบ่อย

| อาการ | สาเหตุ/วิธีแก้ |
|---|---|
| `Cannot find module '../generated/client/client'` | ยังไม่ได้ `pnpm prisma:generate` ใน store-prisma |
| `prisma generate` 403 / โหลด engine ไม่ได้ | เครื่อง/CI ไม่มี network ไป `binaries.prisma.sh` — ใช้ `make test` (docker) หรือเครื่องที่ออกเน็ตได้ |
| route ฟ้องหา repo ไม่เจอใน registry | ลืม `gen:api-wire` (route ที่ฉีด repo) หรือลืมเพิ่ม DI key |
| jest "No tests found" ตอน package ยังว่าง | ยังไม่ได้ scaffold domain — gen domain ก่อน แล้วค่อย test |

---

## ดูต่อ
- โครง/แนวคิด → `docs/backend-structure.md`
- แก้ template/scaffolding → `docs/api-scaffolding.developer-guide.md`
