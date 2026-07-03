# Backend-Test & Infrastructure Layer (v1.5)

> เอกสารนี้ = **migration + gotcha** (rung 1.4→1.5) · **methodology / วิธีเขียน contract & test (ฉบับเว็บ อ่านง่าย)** อยู่ที่
> 📘 [Developer Handbook › Backend Test & Infra](https://bebestdev.com/developer-handbook/backend-test-infrastructure.html)

ตั้งแต่ **v1.5** workspace-generator scaffold เพิ่ม **2 workspace + 1 root entrypoint** เพื่อทำ
**black-box API testing** (ยิง HTTP เข้า service จริง + DB จริง, out-of-process) แบบ local == CI:

| เพิ่มอะไร | ที่ไหน | หน้าที่ |
|---|---|---|
| `workspaces/infrastructure/` | contract (SSOT) + db init/seed + docker-compose + liquibase | นิยาม contract (request/response envelope), test data, topology |
| `workspaces/backend-test/` | node:test harness (standalone package) | 1 action = 1 file, data-driven จาก contract, assert HTTP + **DB record** |
| root `Makefile` | git root | `make api-test` = up → migrate → init → seed → api-up → test → down (สด/รอบ) |

> spec เต็ม (เว็บ): 📘 [handbook › Backend Test & Infra](https://bebestdev.com/developer-handbook/backend-test-infrastructure.html) + DB strategy [handbook › DB Architecture Standard](https://bebestdev.com/developer-handbook/db-architecture-standard.html) (ARCH-STD-001)

---

## ทำไม (why)

- **contract = SSOT** — 1 ไฟล์ envelope (`c*.json`/`e*.json`) เสิร์ฟทั้ง BE (api-test assert) และ FE (mock/MSW) → กัน drift
- **black-box** — เทสต์ยิงเข้า **artifact จริง** (container) ไม่ mock อะไร → จับ bug ที่ integration จริง (route mount, auth, envelope, prisma)
- **assert DB จริง** — HTTP 200 ไม่ได้แปลว่า row ลง DB → `assertDb` ตรวจ side-effect (create/update/delete)
- **local == CI** — `make api-test` เรียก target เดียวกันทั้ง local + CI (docker + liquibase + node:test)

---

## Migrate workspace เดิม → v1.5

**full-auto + idempotent** (รันซ้ำได้ ไม่พัง) — ใช้ driver `apply-migration.sh` (จัดลำดับ + version + log ให้):

```bash
# driver ไล่ทุก version ที่ค้างให้เอง (< 1.4 → 1.4.0 export-strategy ก่อน แล้ว → 1.5.0 backend-test เอง ตามลำดับ)
bash workspace-generator/script-generator/migrate/apply-migration.sh <ws> --to 1.5    # หยุดที่ 1.5 patch ล่าสุด
#   <ws> = git root ที่มี workspaces/node-app · driver รัน migration-v1.5.0.sh (auto-detect SERVICE + DB_SCHEMA)
```

`migration-v1.5.0.sh` ทำให้อัตโนมัติ: scaffold `infrastructure/` + `backend-test/` + merge root Makefile · discover
domain/action เดิมใน core → backfill contract⇄test pair ต่อ action · wire prisma migrations เข้า
`changelog.yaml` (context=migrate) · **หลัง script สำเร็จ driver** (ไม่ใช่ตัว script) จะ bump `template-version` → 1.5.0 + เขียน log ให้

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

## harness design + gotcha

- **pure harness + per-service `_config.ts`** — `backend-test/lib/*` เป็น pure (รับ config เป็น **parameter** ไม่แตะ
  `process.env`) · **test file เป็นคนกำหนด** config โดย import `<service>/_config.ts` (`TARGET {baseUrl,prefix}` +
  `DB {databaseUrl,schema}` ที่อ่าน env + default ต่อ service) แล้วส่งเข้า lib · backend-test = project เดียวทดสอบหลาย
  service → **แต่ละ service คนละ `_config.ts`** (baseUrl/prefix/schema ต่างกัน) · override ได้ด้วย env ตอน run
- **route prefix — ไม่แตะ app source** — คง `app.ts` (`process.env.API_PREFIX ? .. : '/<service>'`) ของ app-owner ไว้ ·
  ⚠️ `@fastify/autoload` mount route ตาม **folder** (`/<domain>-api/<action>`) — **ไม่ apply prefix ของ app.ts** →
  local app อยู่ที่ `/product-api/..` (ไม่มี service prefix) · `_config` `TARGET.prefix` **default `''`** (ยิงตรง local) ·
  harness prepend `TARGET.prefix` + contract path (service-relative) → ถ้ายิงผ่าน gateway ที่มี prefix ค่อยตั้ง `API_PREFIX`
- **telemetry — env (ไม่แตะ app source)** — `unified-telemetry-core@0.3.4` `ConsoleUnifiedTelemetryProvider` (dev-default)
  บั๊ก `ConsoleSpan.getSpanMetadata()` throw → endpoint 500 · **แก้ที่ env:** compose `api` ตั้ง `OTEL_EXPORTER_OTLP_ENDPOINT`
  + `OTEL_*_EXPORTER=none` → OtelProviderService ทำงาน (ไม่ export จริง) · จะเอา trace จริง = ชี้ endpoint ไป collector
- **schema case-fold** — postgres fold identifier เป็น lowercase → DB schema name ใช้ lowercase (`demo_shop`)
  ทั้ง DDL/liquibase/prisma `?schema=`/harness ต้องตรงกัน
- **docker — 3 Dockerfile (แยกหน้าที่)** — webapi app dir มี 3 ไฟล์ · migration เพิ่มแค่ 2 ตัว build (ไม่แตะ `Dockerfile` เดิม):
  | ไฟล์ | build | ใช้เมื่อ |
  |---|---|---|
  | `Dockerfile` | **ไม่ build ในคอนเทนเนอร์** — `COPY prebuilt dist → run` (`node:22-alpine`) | CI เดิม: `release` (MS Agent build dist) → `docker:build` · runtime-only ของ **app-owner** — migration ไม่แตะ |
  | `Dockerfile.build` | **pnpm** `--filter "<app>..."` (topological: core/service/store-prisma → webapi) | **compose default** (`make api-test`) · robust สุด — ไม่พึ่ง nx project-graph ในคอนเทนเนอร์ |
  | `Dockerfile.nx-build` | **nx** `pnpm run build:backend-libs && build:backend-apps` (run-many เลือก project explicit) | ตัวอย่างตรง Azure/nx pipeline · switch compose มาใช้ได้ (verified ทั้งคู่) |
  - ทั้ง `.build`/`.nx-build` = multi-stage `node:22-bookworm-slim` · **runtime stage ต้อง `apt-get install openssl`**
    (bookworm-slim ไม่มี → prisma query engine mismatch) · runtime `fastify start dist/src/app.js` (**ไม่ใช่ main.ts**)
  - ⚠️ `nx run <app>:build` ที่พึ่ง `^build` **ไม่ build deps** ในคอนเทนเนอร์ (nx target-defaults plugin เรียก `pnpm --version`) →
    `.nx-build` เลยใช้ run-many scripts ที่ระบุ project ตรง ๆ · `.build` ใช้ pnpm dependency-graph แทน (เลยเป็น compose default)
  - `.dockerignore` (node-app) กัน host artifacts · compose healthcheck + `make api-up = up -d --build --wait api`
- **verify layer — `make verify-backend` (in-container lint+tsc+unit test · ไม่ต้องมี DB)** — คนละ layer กับ `api-test`:
  | layer | ทำอะไร | ต้องมี DB? |
  |---|---|---|
  | `make verify-backend` / `verify-nx-backend` | **node-app**: libs + apps = lint+tsc+**unit test** ในคอนเทนเนอร์ (integration จริงไป api-test) | ❌ ไม่ต้อง |
  | `make api-test` | **black-box**: compose ยก DB+API จริง แล้วยิง HTTP (contract + assertDb) | ✅ (compose ยกให้) |
  | `make test` | host-side `node:test` (iterate เร็ว ตอน stack ขึ้นแล้ว) | ✅ (ต้อง `api-up` ก่อน) |
  - 2 ไฟล์ที่ **node-app root** (tokenless · glob เดียวกับ `build:backend-*`): `Dockerfile.verify-backend` (**pnpm `--filter`** · default · robust
    ไม่พึ่ง nx graph) + `Dockerfile.verify-nx-backend` (**nx run-many** `lint:backend-libs`&`test:backend-libs`→`*-apps` · ตรง pipeline)
  - migration re-sync ทั้ง 2 ไฟล์ผ่าน `lib/sync-infra.sh` (force copy-if-different · ไม่ sed → เขียนทับให้ตรง template) · runtime = `CMD echo ✅` (build-time verify เท่านั้น ไม่ start service)
  - **libs + apps lint+test**: webapi jest `collectCoverageFrom=plugins/` (exclude `app.ts`/`main.ts`/`telemetry.ts` bootstrap) → scaffold มี `support.test.ts`+`sensible.test.ts` ผ่าน gate 80% · integration จริงไป `make api-test`
  - ⚠️ `*:backend-libs` glob `**/*api-*` จับ webapi app ด้วย → `--exclude=*webapi*,*webpub*,*websub*,*webio*` (template pkg.json + init-system + migration patch) · pnpm variant กันด้วย `--filter "!*webapi*"`
- **prisma generate** — store-prisma ต้องเป็น `"postinstall": "prisma generate"` (ไม่ใช่ `_postinstall` — underscore ไม่ใช่
  lifecycle hook, ไม่ auto-run) → `pnpm install` generate client ให้ · `nx build` ก็ทำอีกชั้น
- **run บน host** (dev): `cd apps/<service>/mcs-fastify && pnpm dev` (app ที่ prefix default) · `make test` ใช้ default ใน
  `_config.ts` (localhost:3010 + DB 5433) · override = ตั้ง env (`API_BASE_URL`/`DATABASE_URL`/..)

---

## ดูต่อ

- [migration-guide.md](./migration-guide.md) — **ladder อัปข้ามหลาย version → ล่าสุด** (เอกสารนี้ = rung 1.4→1.5)
- [export-strategy.md](./export-strategy.md) — v1.4 dual-condition exports (prereq ของ v1.5)
- [backend-structure.md](./backend-structure.md) — โครง core/service/client + DI + ResultV2
- [api-scaffolding.user-guide.md](./api-scaffolding.user-guide.md) — เพิ่ม domain/action (`gen:api-*`)
