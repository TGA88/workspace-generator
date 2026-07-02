# Backend-Test & Infrastructure Layer (v1.5)

ตั้งแต่ **v1.5** workspace-generator scaffold เพิ่ม **2 workspace + 1 root entrypoint** เพื่อทำ
**black-box API testing** (ยิง HTTP เข้า service จริง + DB จริง, out-of-process) แบบ local == CI:

| เพิ่มอะไร | ที่ไหน | หน้าที่ |
|---|---|---|
| `workspaces/infrastructure/` | contract (SSOT) + db init/seed + docker-compose + liquibase | นิยาม contract (request/response envelope), test data, topology |
| `workspaces/backend-test/` | node:test harness (standalone package) | 1 action = 1 file, data-driven จาก contract, assert HTTP + **DB record** |
| root `Makefile` | git root | `make api-test` = up → migrate → init → seed → api-up → test → down (สด/รอบ) |

> spec เต็ม: `developer-handbook/docs/backend-test-project-structure.md` (§8) + DB strategy `db-architecture-standard.md` (ARCH-STD-001)

---

## ทำไม (why)

- **contract = SSOT** — 1 ไฟล์ envelope (`c*.json`/`e*.json`) เสิร์ฟทั้ง BE (api-test assert) และ FE (mock/MSW) → กัน drift
- **black-box** — เทสต์ยิงเข้า **artifact จริง** (container) ไม่ mock อะไร → จับ bug ที่ integration จริง (route mount, auth, envelope, prisma)
- **assert DB จริง** — HTTP 200 ไม่ได้แปลว่า row ลง DB → `assertDb` ตรวจ side-effect (create/update/delete)
- **local == CI** — `make api-test` เรียก target เดียวกันทั้ง local + CI (docker + liquibase + node:test)

---

## Migrate workspace เดิม → v1.5

**full-auto + idempotent** (รันซ้ำได้ ไม่พัง):

```bash
# ⚠️ workspace ที่ยัง < 1.4 → รัน export-strategy migration ก่อน (นำขึ้น 1.4 semantics)
node workspace-generator/script-generator/migrate/apply-export-strategy.mjs <ws>/workspaces/node-app

# แล้วค่อย v1.5 layer (WORKSPACE_ROOT = git root ที่มี workspaces/node-app)
bash workspace-generator/script-generator/migrate/apply-backend-test-infra.sh <ws> [SERVICE] [DB_SCHEMA]
#   [SERVICE]   default = auto-detect apps/*/mcs-fastify
#   [DB_SCHEMA] default = <data-pkg> ตัด -data (เช่น demo-shop-data → demo-shop)
```

script นี้ทำให้อัตโนมัติ: scaffold `infrastructure/` + `backend-test/` + merge root Makefile · discover
domain/action เดิมใน core → backfill contract⇄test pair ต่อ action · wire prisma migrations เข้า
`changelog.yaml` (context=migrate) · bump `template-version` → 1.5.0

**prereq หลัง migrate:**
```bash
cd workspaces/node-app && pnpm install --no-frozen-lockfile \
  && pnpm --filter <ws>/<data-pkg>-store-prisma prisma:generate
cd ../backend-test && pnpm install            # standalone package (tsx + pg)
```

**verify:**
```bash
make api-test                    # pure docker: ทุก domain (bring-up สด → test → down -v)
make api-test DOMAIN=product-api # เฉพาะ domain
```

---

## แก้ contract ให้ meaningful (หลัง scaffold)

scaffold ให้ skeleton ตาม envelope ของ framework (`@inh-lib/common`) แล้ว — เติมตาม action จริง:

- **auth**: ทุก request ใส่ header `"authorization": "Bearer <token>"` (authGuardPreHandler เป็น pre-handler ตัวแรก → 401 ถ้าไม่มี) — template ใส่ให้แล้ว
- **success** → `status 200`, `codeResult "OK"` (จาก `getStatusCodeName(200)` ไม่ใช่ "SUCCESS")
- **validate fail** (command body ไม่ครบ) → `422 PARSE_FAIL` (zod ที่ขอบ, `CommonFailures.ParseFail`)
- **query by id** (route `/:id`) → ไม่มี path 422 · error case จริง = `404 NOT_FOUND` (แก้ e1 ตาม action)
- **duplicate/conflict** → `409 CONFLICT`
- **assert DB จริง** (create/update/delete) → เพิ่ม block `assertDb` ใน contract:
  ```json
  "assertDb": { "query": "SELECT col.. FROM <table> WHERE ..", "rowCount": 1, "row": { "col": "val" } }
  ```
- **setup/teardown**: ราย **action** (`setup.sql`/`teardown.sql`, รันครั้งเดียว before/after) หรือราย **case**
  (`setup.<case>.sql`/`teardown.<case>.sql` + ระบุใน `_cases.json`, รันใน `it()` เฉพาะเคส) · ลบเฉพาะของที่ตัวเองใส่ (scoped by id/key)

---

## gotcha (เจอจริงตอน validate กับ demo-shop-system)

- **`API_PREFIX=''`** — service mount route ที่ `/<domain>-api/..` (contract path เป็น service-relative
  เพราะ folder จัดกลุ่มต่อ service แล้ว) · app.ts ใช้ `process.env.API_PREFIX ?? '<default>'` (**`??` ไม่ใช่ `? :`** —
  ไม่งั้น '' เป็น falsy แล้ว fallback) · compose api ตั้ง `API_PREFIX=` (ว่าง)
- **telemetry** — `unified-telemetry-core@0.3.4` `ConsoleUnifiedTelemetryProvider` (dev-default) มีบั๊ก
  `ConsoleSpan.getSpanMetadata()` throw → endpoint 500 · `create-telemetry.ts` ใช้ **`NoOpUnifiedTelemetryProvider`**
  เมื่อไม่มี OTEL endpoint (จะเอา trace จริง = ตั้ง `OTEL_EXPORTER_OTLP_ENDPOINT`)
- **schema case-fold** — postgres fold identifier เป็น lowercase → DB schema name ใช้ lowercase (`demo_shop`)
  ทั้ง DDL/liquibase/prisma `?schema=`/harness ต้องตรงกัน
- **docker** — webapi Dockerfile = multi-stage `node:22-bookworm-slim` (prisma binaryTarget `debian-openssl-3.0.x`) ·
  build ทุก lib (require → dist) ก่อน tsc webapi · runtime `fastify start dist/src/app.js` (**ไม่ใช่ main.ts** —
  main.ts ไม่ `.listen()` · fastify-cli boot app plugin เอง) · `.dockerignore` (node-app) กัน host artifacts ·
  compose api มี healthcheck + `make api-up` = `up -d --build --wait api` (รอ healthy ก่อน test)
- **run บน host** (dev): `cd apps/<service>/mcs-fastify && DATABASE_URL=..5433..?schema=<schema> PORT=3010 API_PREFIX='' pnpm dev`

---

## ดูต่อ

- [export-strategy.md](./export-strategy.md) — v1.4 dual-condition exports (prereq ของ v1.5)
- [backend-structure.md](./backend-structure.md) — โครง core/service/client + DI + ResultV2
- [api-scaffolding.user-guide.md](./api-scaffolding.user-guide.md) — เพิ่ม domain/action (`gen:api-*`)
