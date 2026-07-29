# Changelog

รูปแบบตาม [Keep a Changelog](https://keepachangelog.com/) · เวอร์ชันตาม [SemVer](https://semver.org/) · Node 22+

> **อัป workspace เดิมขึ้นเวอร์ชันใด ๆ:** ใช้ driver คำสั่งเดียว — `apply-migration.sh <ws>` (ดู [migration-guide](./docs/migration-guide.md)) ·
> วิธีเพิ่ม migration/version (contributor) → [CONTRIBUTING](./CONTRIBUTING.md)

---

## [Unreleased]

_(ยังไม่มี — รุ่นถัดไปเริ่มจดที่นี่)_

## [1.7.0] — 2026-07-29

> ที่มา: dogfood `ws-scaffold-web` ตอน auth-portal **P-PW.5c** (ตั้ง base ที่ 2 = `admin-portal`) — พบว่าการแปลง
> Next app เป็น **static export** ต้องแก้มือ **7 จุดเดิมซ้ำทุกครั้ง** (auth-portal ทำไปแล้วรอบหนึ่งตอน P-PW.0
> แต่ไม่เคยยกกลับเข้า template) ⇒ base ที่ 3 ก็จะทำซ้ำอีก

### Added
- **`new-web.sh` เลือก deploy mode ได้ตอน gen** — `new-web.sh <ws> <project> [generator-dir] [standalone|static]`
  - **default `standalone`** = พฤติกรรมเดิมของ v1.6.x **ไม่เปลี่ยน** · mode ผิด → fail พร้อม usage (exit 1)
  - **mode อยู่ที่ `$4` โดยตั้งใจ** — `$3` เป็น `GENERATOR_DIR` มาแต่เดิม แทรกตรงนั้นจะพัง caller เก่าทุกตัว
  - `static` → `output:'export'` + ลบ `middleware.ts` + วาง overlay ฉบับ static ให้ครบชุด
  - เหตุผลที่ต้องทำที่ generator ไม่ใช่ปล่อยให้ copy เอง: **mode เปลี่ยนพร้อมกัน 4 ไฟล์** (`next.config.mjs` ·
    `app/[locale]/layout.tsx` · `app/(public)/layout.tsx` · `i18n/request.ts` + ต้องมี `messages/index.ts`
    และต้อง**ไม่มี** `middleware.ts`) — การทิ้ง `next-config-mjs-{static,standalone}` ไว้ให้ copy แก้ให้แค่ 1 ใน 4
- `template/project/web/nextjs-static-overlay/` — layout/i18n/messages ฉบับ static (ไม่มี `getMessages()`/
  `cookies()`/`requestLocale` ที่พึ่ง request context ซึ่ง `output:'export'` ไม่มี)

### Fixed
- **layout ซ้อน `<html>`/`<body>` 3 ชั้น** (`app/layout.tsx` + `app/[locale]/layout.tsx` + `app/(public)/layout.tsx`
  ต่าง render เอง) → เหลือเจ้าของเดียวที่ root · **ผิดทั้ง 2 mode ไม่ใช่เฉพาะ static**
- `app/(public)/layout.tsx` ประกาศ `params.locale` ทั้งที่ route group นั้นไม่มี segment · ชื่อ fn ซ้ำ
  `LocaleLayout` → `PublicLayout` · ตัด `cookies()` ที่อ่าน `NEXT_LOCALE` มาทับ locale ของ route param
- root layout `title: 'Smart Prescription'` (ชื่อโปรเจกต์อื่นค้างใน template) → placeholder `'App'` + TODO
- **`new-web.sh` ทำ `.gitignore` ของ template หาย** — `cp -r .../nextjs/*` (glob ไม่หยิบ dotfile) →
  `cp -r .../nextjs/.` · เดิมมี workaround copy `.env.example` แยกบรรทัดเฉพาะไฟล์นั้น
- ต้นฉบับ `next-config-mjs-{static,standalone}` ไม่ติดไปกับโปรเจกต์ที่ gen แล้ว (เลือก mode ไปแล้วตั้งแต่ต้น)
- เติม explicit return type ให้ layout ทุกตัว (arm lint ของ adopter บังคับ)

### Migration
- `migration-v1.7.0.sh` = **no-op โดยตั้งใจ** — release นี้แตะเฉพาะ template ที่ใช้ตอน gen + `new-web.sh`
  ซึ่งไม่ถูก copy เข้า workspace ⇒ ไม่มีอะไรใน workspace เดิมต้องแก้ · **ไม่เรียก `sync-infra`**
  (ไม่มีไฟล์ generator-owned เปลี่ยนสักตัว — เรียกไปมีแต่ความเสี่ยงทับ customization ของ repo)
- แอปที่แปลง static ด้วยมือไปแล้วก่อน v1.7.0 **ยังถูกต้อง** — v1.7.0 ทำให้แอป *ตัวถัดไป* ไม่ต้องทำซ้ำ

## [1.6.0] — 2026-07-28
**Frontend loop alignment (harvest จาก auth-portal P-PW.3) + `packages/` taxonomy**

> 📖 [migration-v1.6](./docs/migration-v1.6.md) — **อ่านก่อน upgrade**: อะไร "ถึง workspace เดิม" vs "เฉพาะ project ที่ generate ใหม่" · ทำไม migration รุ่นนี้ patch `pnpm-workspace.yaml`/root globs เอง · วิธีซ่อม lib ที่เคยโดน `update_alias_path.sh` ตัวเก่าทำพัง

### Fixed
- **🔴 `tools/update_alias_path.sh` — เขียนใหม่ทั้งตัว (sed line-surgery → brace-matching patch ด้วย node)** · ของเดิมใช้ `sed` command `c\` แทนที่ *บรรทัด* ที่ match แล้วเดาขอบเขตบล็อก (พฤติกรรม BSD/GNU sed ต่างกัน) ⇒ **เจอจริงบน reference workspace**: `jest.config.ts` ได้ `moduleNameMapper` **ซ้ำ 2 บล็อก** (duplicate key = TS parse error) · `tsconfig{,.build}.json` เสีย key อื่นใน `compilerOptions` + วงเล็บปิดหาย · ตัวใหม่แทนที่ **เฉพาะเนื้อในบล็อกเป้าหมาย** โดยไล่วงเล็บจริง (ข้าม string/comment) → comment/key อื่น/การจัดรูปนอกบล็อกไม่ถูกแตะ · **fail-closed**: หาบล็อกไม่เจอ = ไม่แตะไฟล์ + บอกวิธีแก้ · idempotent (รันซ้ำ = 0 diff)

### Added
- **`packages/` taxonomy** — โฟลเดอร์ที่ 3 คู่ `apps/`+`libs/` สำหรับ lib ที่ publish ข้าม repo · แยกตาม environment (`packages/{frontend,backend}/`) · เกณฑ์ mechanical = `publishConfig.access` (`public` → `packages/` · `restricted` → `libs/`) · template `pnpm-workspace.yaml` + root globs 6 ตัว + README section ใหม่ · **migration patch ให้ workspace เดิมด้วย** (sync-infra ไม่แตะ 2 ไฟล์นี้โดยดีไซน์)
- **`migration-v1.6.0.sh`** — rung ใหม่: `sync-infra` + patch workspace-owned 2 ไฟล์ (idempotent + guard)

### Changed
- **features template restructure** — ตัวอย่างใน template เป็นโครง canonical ตาม handbook `frontend-structure` §3: `lib/feature-<name>/{pages/*.page.tsx, components, hooks/hook-*.ts, logic, types, mocks, main.ts}` (เดิม `containers/` + `hooks/*/functions/`) · stories อยู่ `__stories__/` + play ติด `tags: ['ci']` · `gen_front_skelton.sh` สร้างโครงใหม่ตาม
- **⭐ README §ui/api/common-functions — reframe เป็น *intent* ไม่ใช่ capability** (ตั้งใจให้ฝั่งไหนใช้ · ไม่ใช่ "ใช้ builtin ของอะไร") + คำเตือน backend-only/private-key ห้ามตั้งชื่อ `common` (secret รั่วเข้า frontend bundle) — นิยามเดิมทำให้คนตั้งชื่อผิดจริงมาแล้ว
- **docs** — `infrastructure/` + `backend-test/` = **on-demand** (`gen:infra`) ไม่ใช่ของที่มาพร้อม workspace ทุกอัน
- **webapi template** — ตัด placeholder `src/api-client/.gitkeep` (โฟลเดอร์เปล่าที่ทำ app ใหม่ drift จาก convention จริง)
- **exports convention (frontend lib)** — `.` + exact entry `./feature-<name>` ต่อ sub-module ชี้ตรงเข้า `main` (dual-condition ครบ) · consumer import `@scope/<lib>/feature-<name>` ไม่ต้องต่อ `/main` · deep import ทำไม่ได้ = boundary enforce ด้วยกลไก · **เพิ่ม sub-module ใหม่ต้องเพิ่ม exports entry เสมอ** — gen ได้ด้วย tool ใหม่ด้านล่าง
- **⚠️ tool ใหม่ `tools/generate-exports-web.sh`** — `pnpm gen:exports` ของ frontend lib ชี้ตัวนี้แล้ว · **ตัวเดิม `generate-exports.sh` = backend-only** (key จาก `src/*/index.ts`) — รันใน frontend lib โครงใหม่จะได้ exports ว่างทับของเดิม ห้ามใช้ข้าม convention (ตัวใหม่มี guard: 0 entry = abort ไม่แตะ `package.json`)
- **storybook-host template** — script `test-storybook` + devDeps `@storybook/test-runner` + `http-server` (acceptance ผ่าน play function — ดู handbook `storybook-testing`)
- **fix สะสม** — react-pin ใน `jest.config.features.ts` ครอบ subpath (กัน dual-React จาก `react-dom/client`) · lib scripts อ่าน npm scope จริงจาก root `package.json` (เดิมใช้ชื่อ dir) · `cp` template หยิบ dotfiles (`.gitignore` ไม่หายแล้ว) · vite `renderChunk` ใส่ return type

## [1.5.2] — 2026-07-03
**Docs: wire Developer Handbook + ship workspace WORKSPACE.md**

- **ship `WORKSPACE.md`** (operational cheat sheet: setup · `make` test · `pnpm gen:api-*` · migrate · ลิงก์ handbook) เข้า workspace — **generator-owned** เข้า `sync-infra` manifest → **force-sync ทุก workspace** (ไม่ชน `README.md` ของโปรเจกต์) · `migration-v1.5.2.sh` เรียก sync-infra · create-workspace วาง `WORKSPACE.md` + `README.md` (pointer สั้น) ให้ workspace ใหม่
- **README (generator)** — เพิ่ม `🧭 หาอะไรอยู่?` map + section `🧪 รัน test (make)` + ลิงก์ **[Developer Handbook](https://bebestdev.com/developer-handbook/)** (architecture/coding/testing methodology) · แบ่งบทบาทชัด: handbook = "เขียน/ทำไม" · repo = "ใช้/รัน + migration + contribute"
- **staleness** — `docs/backend-test-migration.md`: ref ภายนอก → URL handbook จริง · เกลา "driver bump template-version"
- 📖 [migration-guide](./docs/migration-guide.md)

## [1.5.1] — 2026-07-03
**Migration system + generic infra sync**

- **Migration driver** `apply-migration.sh` — เช็ค `template-version` → รัน migration ที่ค้างตามลำดับ (semver) → bump version + เขียน audit log
- migration ตั้งชื่อตามเวอร์ชัน (`migration-v<semver>.{sh,mjs}`) · flags `--to <ver|minor>` / `--dry-run` / `--list` / `--rerun`
- **retry เมื่อพัง** — migration ที่พังไม่ bump version → รัน driver ซ้ำ = retry อัตโนมัติ (ไม่ downgrade)
- **audit log** — `workspaces/node-app/workspace-history/migration-history/` (index + detail ต่อ run + `gen=<sha>`)
- **re-sync generic infra** — utility `lib/sync-infra.sh` ดึง generator-owned tokenless files (verify Dockerfiles + `tools/` + conventions) ให้ workspace เดิมที่ scaffold ก่อนหน้า
- 📖 [migration-guide](./docs/migration-guide.md)

## [1.5.0] — 2026-07-03
**Backend-test & infrastructure layer**

- `workspaces/infrastructure/` (contract SSOT + db init/seed + docker-compose + liquibase) + `workspaces/backend-test/` (node:test **black-box**) + root `Makefile`
- `make api-test` — up → migrate → init → seed → api-up (docker build + wait) → test → down · assert ได้ทั้ง HTTP envelope + DB record
- 3 build Dockerfiles (`Dockerfile` / `.build` pnpm / `.nx-build` nx) + in-container verify layer (`make verify-backend` / `verify-nx-backend`)
- 📖 [backend-test-migration](./docs/backend-test-migration.md)

## [1.4.0] — 2026-06-14
**Dual-condition export strategy**

- ทุก lib ใช้ `development` export condition → lint/test/build รันได้ทันที **ไม่ต้อง build local dependency ก่อน** · production ยังใช้ `dist` เหมือนเดิม
- 📖 [export-strategy](./docs/export-strategy.md)

## [1.3.0] — 2025-10-16 · [1.3.2] — 2026-02-11
- ปรับ scaffolding + config (ดู [README_v1_3.md](./README_v1_3.md))

## [1.2.0] — 2025-07-03
- รองรับ **Node 22+** (ก่อนหน้านี้ Node ≤ 20) — ดู [README_v1.md](./README_v1.md)

## [1.0.0] – [1.1.7] — 2025-02 … 2025-03
- generator รุ่นแรก: scaffold pnpm monorepo (Nx) + frontend (Next.js/Storybook) + backend API packages
