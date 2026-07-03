# Changelog

รูปแบบตาม [Keep a Changelog](https://keepachangelog.com/) · เวอร์ชันตาม [SemVer](https://semver.org/) · Node 22+

> **อัป workspace เดิมขึ้นเวอร์ชันใด ๆ:** ใช้ driver คำสั่งเดียว — `apply-migration.sh <ws>` (ดู [migration-guide](./docs/migration-guide.md)) ·
> วิธีเพิ่ม migration/version (contributor) → [CONTRIBUTING](./CONTRIBUTING.md)

---

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
