# Changelog

รูปแบบตาม [Keep a Changelog](https://keepachangelog.com/) · เวอร์ชันตาม [SemVer](https://semver.org/) · Node 22+

> **อัป workspace เดิมขึ้นเวอร์ชันใด ๆ:** ใช้ driver คำสั่งเดียว — `apply-migration.sh <ws>` (ดู [migration-guide](./docs/migration-guide.md)) ·
> วิธีเพิ่ม migration/version (contributor) → [CONTRIBUTING](./CONTRIBUTING.md)

---

## [Unreleased]
**Frontend loop alignment (harvest จาก auth-portal P-PW.3)**

- **features template restructure** — ตัวอย่างใน template เป็นโครง canonical ตาม handbook `frontend-structure` §3: `lib/feature-<name>/{pages/*.page.tsx, components, hooks/hook-*.ts, logic, types, mocks, main.ts}` (เดิม `containers/` + `hooks/*/functions/`) · stories อยู่ `__stories__/` + play ติด `tags: ['ci']` · `gen_front_skelton.sh` สร้างโครงใหม่ตาม
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
