# API Scaffolding — Developer Guide (สำหรับ maintainer ของ generator)

เอกสารนี้สำหรับคนที่ดูแล/แก้ตัว generator เอง (ไม่ใช่ผู้ใช้ทั่วไป) — อธิบายว่า template ฝั่ง API + scaffolding script ทำงานยังไง และจะแก้ pattern ได้ที่ไหน

ผู้ใช้ทั่วไปดู `api-scaffolding.user-guide.md` พอ; แนวคิดโครงดู `backend-structure.md`

---

## 1. ที่อยู่ของไฟล์

```
script-generator/
  template/project/                    # base shells (สร้างด้วย new-api*.sh)
    api-core/    api-service/  api-client/
    store-prisma/  webapi/
  template/scaffold/                   # ตัวสำหรับ scaffolding (ไม่ใช่ base)
    api-domain/{core,service,client}/__DOMAIN_API__/   # vertical slice ของ 1 domain
    api-wire/{data,route,prisma}/                      # repo + route + model
    api-action/{command,query}/{core,service,client}/  # action เดี่ยว (verb-tokenized)
    api-contract/{contract,test,seed}/                 # contract⇄backend-test pair ต่อ action (§9)
  template/infrastructure/             # skeleton: docker-compose + liquibase + db/ + contract/ (§9)
  template/backend-test/               # skeleton: node:test harness (lib/) + _conformance (§9)
  template/workspace/root/             # Makefile + .gitattributes + .editorconfig (§9)
  new-apicore.sh new-apiservice.sh new-apiclient.sh    # สร้าง base package
  new-storeprisma.sh new-webapi.sh
  new-api-domain.sh                    # scaffold domain slice (grouped)
  new-api-wire.sh                      # scaffold data repo + route + model (auto-chain contract §9)
  new-api-action.sh                    # scaffold action เดี่ยว (command/query) เข้า domain เดิม
  new-infrastructure.sh                # one-time: infrastructure + backend-test + root Makefile (§9)
  new-api-contract.sh                  # contract⇄backend-test pair ต่อ action (§9)
  template/workspace/tools/gen-api-domain.sh           # wrapper (ติดไปกับทุก workspace)
  template/workspace/tools/gen-api-wire.sh
  template/workspace/tools/gen-api-action.sh
  template/workspace/tools/gen-infra.sh                # wrapper → new-infrastructure.sh
  template/workspace/tools/gen-api-contract.sh         # wrapper → new-api-contract.sh
  template/workspace/package.json      # มี npm script gen:api-domain / gen:api-wire / gen:infra / gen:api-contract
```

แยกแนวคิด: **base template** = เปลือก package เปล่า (config + shared utils, ไม่มี domain) — `new-api*.sh` ก๊อปมา; **scaffold template** = เนื้อ domain ที่เติมเข้า base ทีหลัง — `new-api-domain/wire.sh` ก๊อป+แทน token

---

## 2. base templates (project shells)

`new-apicore/service/client.sh` ก๊อป `template/project/api-*` แล้ว sed แทน:
- `exm-api` → PROJECT_NAME (เช่น `shared-api`)
- `gu-example-system` → WORKSPACE
- ตั้งชื่อ package `@<ws>/<project>-{core,service,client}`

base ปัจจุบัน (หลังเคลียร์ bible) มี:
- **api-core**: `src/types`, `src/logics` + exports `.`/`./logics/*` + peer `@inh-lib/unified-route`
- **api-service**: `src/shared/` (telemetry pipeline + endpoint-helpers + pre-handlers: check-telemetry / create-map-req-to-input / auth-guard) + exports `.`/`./shared/*` + peer unified-route/telemetry-core/telemetry-middleware/zod
- **api-client**: `src/client.ts` (base `ApiClient`), `src/mocks` (generic msw), `src/types`, `src/logics`
- **store-prisma**: `dbclient.ts` (v6 import `../generated/client/client`), `schema.prisma` (base, model ตัวอย่าง comment), exports `.` เท่านั้น, deps prisma v6
- **webapi**: `plugins/telemetry.ts` + `shared-function/create-telemetry.ts` (env-driven OTEL/Console) + `.env.example` + deps `@inh-lib/*` + `@opentelemetry/*`

> shared/ utils ฝั่ง service พึ่งแค่ `@inh-lib/*` + relative — ไม่อ้าง workspace scope จึงก๊อปข้าม workspace ได้ตรงๆ

---

## 3. scaffold templates + token

`new-api-domain.sh` / `new-api-wire.sh` ก๊อป `template/scaffold/...` แล้วแทน token (ทั้งใน "เนื้อไฟล์" และ "ชื่อ path"):

| token | ความหมาย | ตัวอย่าง (domain=order) |
|---|---|---|
| `__DOMAIN__` | domain ตัวเล็ก | `order` |
| `__Domain__` | domain CamelCase | `Order` |
| `__DOMAINUP__` | domain UPPER (`-`→`_`) | `ORDER` |
| `__DOMAIN_API__` | ชื่อ folder domain | `order-api` |
| `__WS__` | workspace/scope | `demo-shop-system` |
| `__API__` | api package | `shared-api` |
| `__DATA__` | data package | `demo-shop-data` |

การแทนชื่อ path ใช้ลูป rename ทีละ basename (กัน token ซ้อนหลายชั้นในเส้นเดียว)

**แก้ pattern ที่ gen ออกมา** = แก้ไฟล์ใน `template/scaffold/api-domain/` หรือ `api-wire/` (เป็น TS จริงที่ token-ized) แล้ว gen ใหม่จะได้ของใหม่ทันที

ที่มาของ scaffold template: ยกมาจาก demo `demo-shop-system` (product-api) ที่ผ่าน `make test` แล้ว tokenize (product→`__DOMAIN__`, Product→`__Domain__`, demo-shop-system→`__WS__`, shared-api→`__API__`)

---

## 4. scaffolding ทำอะไรบ้าง (นอกจากก๊อปไฟล์)

`new-api-domain.sh`:
- gen `core/service/client/src/<domain>-api/...`
- เพิ่ม exports ใน package.json ของ 3 layer (`./<domain>-api/command/*` ฯลฯ)
- เพิ่ม `export * from './<domain>-api'` ใน `core/src/index.ts`

`new-api-wire.sh`:
- gen `store-prisma/src/<domain>-api/... (Action-Based)` (repo impl) + เพิ่ม store-prisma exports
- gen `webapi/src/routes/<domain>-api/...` (route)
- append prisma model ใน `schema.prisma` (ถ้ายังไม่มี)
- เพิ่ม workspace deps (`<api>-core/service`, `<data>-store-prisma`) ใน webapi package.json

---

## 5. wrapper + npm script

`tools/gen-api-domain.sh` / `gen-api-wire.sh` (ติดไปกับ workspace) คำนวณ path: cwd = `workspaces/node-app` → `../..` = workspace dir, `../../..` = dir แม่ที่มี generator เป็น sibling (override ด้วย `WORKSPACE_GENERATOR_DIR`) แล้วเรียก `new-api-*.sh` ให้ — เพื่อให้ user รัน `pnpm gen:api-domain ...` ได้โดยไม่ต้องจำ path bash

ถ้าเพิ่ม scaffolding ตัวใหม่: เพิ่ม `new-api-xxx.sh` + `template/workspace/tools/gen-api-xxx.sh` (wrapper) + npm script ใน `template/workspace/package.json`

---

## 6. promote: grouped → standalone (ทำมือ)

ย้าย domain จาก shared-api เป็น package เดี่ยว:
1. สร้าง base package ใหม่: `new-apicore/service/client.sh <ws> <domain>-api <scope>`
2. ย้าย `shared-api/{core,service,client}/src/<domain>-api/*` → `<domain>-api/{...}/src/*` (เอา wrapper `<domain>-api/` ออก 1 ชั้น)
3. แก้ import: `@<ws>/shared-api-core/<domain>-api/...` → `@<ws>/<domain>-api-core/...`
4. แก้ exports: `./<domain>-api/command/*` → `./command/*`
5. แก้ consumer (route/wire) ให้ชี้ package ใหม่ + ลบ domain เดิมจาก shared-api + ลบ `export * from './<domain>-api'` ใน core index

> มีคำสั่งอัตโนมัติแล้ว: `promote-api-domain.sh` / `demote-api-domain.sh` (เรียกผ่าน `pnpm gen:api-promote` / `gen:api-demote`) — ย้ายไฟล์ + แก้ exports/index/import/deps + relative-shared-depth ให้ครบ; เหลือ root-aggregate client ที่ต้องแก้เอง (custom code)

---

## 7. prisma v6/v5

- schema generator active = **v6** (`prisma-client`, output `../generated/client`) → client ออกที่ `store-prisma/generated/client/` (relative จากไฟล์ schema), import `../generated/client/client`
- deps ต้องเป็น `prisma`/`@prisma/client` `^6`
- generated client ถูก gitignore (`**/generated/client/`) — สร้างใหม่ทุกเครื่องด้วย `prisma:generate`
- v5: เปิด comment ชุด v5 ใน schema (output ไป node_modules) + `build` = `build:prisma` + dbclient import `@prisma/<pkg>-client`

---

## 8. verify การแก้ template

หลังแก้ scaffold/base template ให้ลอง gen จริงแล้ว typecheck:
```bash
# ใน workspace ทดสอบ
pnpm gen:api-domain shared-webapi shared-api thing
pnpm gen:api-wire   shared-webapi shared-api demo-shop-data demo-shop-webapi thing
# core/service/client tsc+jest; store-prisma+webapi ต้อง prisma:generate ก่อน (หรือ make test)
```
หรือใช้ `make test` (docker) ตรวจครบวงรวม prisma v6 generate

---

## 9. infrastructure + backend-test + contract (api-test ระดับ API)

scaffold ชุดที่ 2 (นอกจาก code slice) = **โครงรัน api-test** — black-box out-of-process, runner **`node:test`**,
data-driven จาก **contract (SSOT)**. ที่มาของ pattern: ยกจากโครง `workspaces/{node-app,infrastructure}` ของ
**ระบบอ้างอิงเดิม** แล้วเก็บกวาด (สะกด `contract`/`teardown` ให้ถูก · เพิ่ม `_cases.json` · เปลี่ยน jest→node:test ·
เพิ่ม root Makefile + db scope ladder).

### 9.1 `new-infrastructure.sh <WS> <SERVICE> <DB_SCHEMA> [SCOPE] [DATA_PKG] [API_PKG]` (one-time/system)
ก๊อป 3 template แล้ว tokenize:
- `template/infrastructure/` → `workspaces/infrastructure/` (rename path token `__DB_SCHEMA__` → db folder)
- `template/backend-test/` → `workspaces/backend-test/` (rename `__SERVICE__` ในชื่อไฟล์ conformance)
- `template/workspace/root/Makefile` → root (มี Makefile อยู่แล้ว → เขียน `Makefile.backend-test.example`) + `.gitattributes`/`.editorconfig`

derive: `DB_UP = upper(DB_SCHEMA, -→_)` · `DB_SCHEMA_NAME = DB_UP` · `DB_NAME = DB_UP_DATA_INTEGRATION` ·
default `SCOPE=shared-webapi` · `DATA_PKG=<DB_SCHEMA>-data` · `API_PKG=shared-api`. idempotent (skip ถ้ามีแล้ว)

### 9.2 `new-api-contract.sh <WS> <SERVICE> <DOMAIN> [ACTION]` (ต่อ action — "คู่กัน")
สร้าง pair + domain seed:
- `infrastructure/contract/<service>/<domain>-api/<action>/` (c1/e1.json + setup/teardown.sql + _cases.json)
- `backend-test/<service>/<domain>-api/<action>.test.ts` (วน `_cases.json`)
- ครั้งเดียว/domain: `db/<db-schema>/seed/<domain>-api/{base.sql,base.down.sql}` + **แทรก changeSet** ที่ anchor
  `# ▼ GEN:DOMAIN-SEED-ANCHOR ▼` ใน `changelog.yaml` (context=seed, label=domain:<domain>-api) ผ่าน awk
  · ⚠️ ทุก changeSet gen พร้อม **`rollback`** ชี้ `base.down.sql` เสมอ (init/seed skeleton ก็มี `*.down.sql` คู่)

`ACTION` ว่าง = default `create-<domain>` + `get-<domain>` · **method** derive จาก verb
(`get/list/find/search→get`, `update/edit/patch→put`, `delete/remove→delete`, อื่น→`post`) ·
db-schema folder auto-detect จาก `find infrastructure/db -name seed` · idempotent (skip existing, changeSet ครั้งเดียว)

### 9.3 auto-chain จาก wire
`new-api-wire.sh` เรียก `new-api-contract.sh` ท้ายสุด (wire รู้ `WEBAPI_APP`=service + `DOMAIN`) →
ได้ pair อัตโนมัติในโฟลว์หลัก · **opt-out ด้วย `SKIP_CONTRACT=1`**

### 9.4 token เพิ่ม (นอกจาก §3)
| token | ความหมาย | ตัวอย่าง |
|---|---|---|
| `__SERVICE__` | webapi app (service) | `demo-shop-webapi` |
| `__DB_SCHEMA__` | db folder (kebab) | `demo-shop` |
| `__DB_SCHEMA_NAME__` | postgres schema (upper) | `DEMO_SHOP` |
| `__DB_NAME__` | postgres database | `DEMO_SHOP_DATA_INTEGRATION` |
| `__SCOPE__` / `__DATA_PKG__` | libs group / data package | `shared-webapi` / `demo-shop-data` |
| `__ACTION__` / `__VERB__` / `__METHOD__` | action / verb / HTTP method | `create-product` / `create` / `post` |

> ⚠️ ลำดับ sed: `__DB_SCHEMA_NAME__` ก่อน `__DB_SCHEMA__` · `@__WS__` ก่อน `__WS__` (กัน prefix ชน)

### 9.5 verify การแก้ template ชุดนี้
```bash
# ในโฟลเดอร์แม่ (workspace + generator = sibling)
bash workspace-generator/script-generator/new-infrastructure.sh <ws> demo-shop-webapi demo-shop
bash workspace-generator/script-generator/new-api-contract.sh   <ws> demo-shop-webapi product
```
เช็ค: ไม่มี token `__…__` ค้าง · JSON valid (`node -e JSON.parse`) · TS syntax (node:test harness) ·
changelog มี changeSet ต่อ domain · แล้ว `cd workspaces/backend-test && pnpm install && make api-test`
(ต้องมี docker + service Dockerfile)
