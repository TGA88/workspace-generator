# Contributing — workspace-generator

คู่มือสำหรับ **contributor** ที่มาพัฒนาตัว generator เอง (ไม่ใช่ user ที่เอาไปสร้าง workspace)

> user guide → [README](./README.md) · การอัป workspace → [migration-guide](./docs/migration-guide.md)

---

## 1) โครง repo

```
workspace-generator/
├── README.md · CHANGELOG.md · CONTRIBUTING.md
├── README_v1*.md                      # snapshot README ของเวอร์ชันเก่า (archive · อย่าแก้)
├── docs/                              # เอกสารเชิงลึกต่อหัวข้อ (structure / scaffolding / migration ต่อรุ่น)
└── script-generator/
    ├── create-workspace.sh            # สร้าง monorepo เปล่า (pnpm + nx)
    ├── init-system.sh                 # install + config tools
    ├── update-workspace-config.sh     # sync root package.json + tsconfig/jest/lint base
    ├── new-*.sh                       # scaffold project แต่ละชนิด (web / api-core / webapi / ...)
    ├── promote/demote/new-api-*.sh    # API scaffolding (เบื้องหลัง pnpm gen:api-*)
    ├── template/                      # ★ SSOT ของไฟล์ที่ generate ออกไป (workspace/ + project/)
    │   └── workspace/package.json     # ★ VERSION SSOT (ดู §3)
    └── migrate/                       # ★ migration system (ดู §3)
        ├── apply-migration.sh         #   driver
        ├── migration-v<semver>.{sh,mjs}  # 1 ไฟล์ = 1 เวอร์ชัน
        └── lib/                       #   utility ที่ migration เรียกใช้ (เช่น sync-infra.sh)
```

---

## 2) Conventions

- **Shell = bash 3.2-safe** — target คือ macOS default (`/bin/bash` 3.2.57) → **ห้ามใช้** associative array, negative index (`${a[-1]}`), `mapfile`/`readarray`, `${x,,}` · ใช้ได้: `${!var}`, `<<<`, `< <()`, `sort -V`
- **Idempotent เสมอ** — ทุก script ต้องรันซ้ำได้ไม่พัง (guard/check ก่อนแก้ทุกจุด)
- **git identity** — commit เป็น `Innovahaus.owner <innovahaus.owner@gmail.com>`
- **ไม่ push/merge/tag เอง** — เตรียมงานบน branch แล้วให้ maintainer review + merge + tag + push
- **ไม่แตะ app source ของ workspace** — migration แก้ได้เฉพาะ tooling/infra/config (ดู §3 migration contract)
- **แก้ template = แก้ที่ `template/`** — อย่าแก้ output ที่ generate ไปแล้ว
- แก้ scaffolding/template ของ API → [docs/api-scaffolding.developer-guide.md](./docs/api-scaffolding.developer-guide.md)

---

## 3) Migration & versioning (สำคัญ)

### 3.1 โมเดล

- **Version SSOT = `script-generator/template/workspace/package.json` `"version"`** — bump ที่นี่ที่เดียวทุกครั้งที่ออกเวอร์ชันใหม่
- **workspace marker = `workspaces/node-app/template-version`** (`<major>.<minor>.<patch>`) — บอกว่า workspace อยู่เวอร์ชันไหน · **driver เป็นคนเขียน** (migration ไม่ต้องเขียนเอง)
- **ทุกเวอร์ชัน (minor และ patch) = 1 ไฟล์ `migration-v<semver>.{sh,mjs}`** — ชื่อบอกเวอร์ชันปลายทาง
- **หน้าที่แยกชัด:**
  - `apply-migration.sh` (driver) = จัดลำดับ + เขียน `template-version` + เขียน log
  - `migration-v*` = "งาน" ที่พา workspace ขึ้นเวอร์ชันนั้น (จะเรียก `lib/*` utility หรือไม่ก็ได้)
  - `lib/sync-infra.sh` = utility copy generic infra (ไม่ยุ่ง version/log)

### 3.2 Migration contract (กติกาที่ driver คาดหวังจากทุก `migration-v*`)

1. **ชื่อไฟล์** = `migration-v<major>.<minor>.<patch>.sh` หรือ `.mjs` (driver dispatch ตามนามสกุล: `.mjs`→node, อื่น→bash)
2. **รับ `<WORKSPACE_ROOT>` (git root) เป็น arg แรก** — derive `workspaces/node-app` เอง (`.mjs` รับ node-app path ตรง ๆ ก็ได้)
3. **idempotent** — รันซ้ำ/รันบน workspace ที่ทำแล้วต้องไม่พัง (guard ก่อนแก้)
4. **ห้ามเขียน `template-version` / log เอง** — driver ทำให้หลัง migration สำเร็จ (ถ้าเขียนเองจะชนกับ driver)
5. **แตะได้เฉพาะ tooling/infra/config** — ห้ามแก้ app source ของ workspace

### 3.3 เพิ่ม migration ใหม่ = ออกเวอร์ชันใหม่

**MINOR (เปลี่ยนโครง scaffold · เช่น 1.5 → 1.6):**
1. bump `template/workspace/package.json` `"version"` → `1.6.0` (SSOT)
2. เขียน `migrate/migration-v1.6.0.sh` (หรือ `.mjs`) ตาม [contract §3.2](#32-migration-contract-กติกาที่-driver-คาดหวังจากทุก-migration-v)
3. เพิ่มแถวใน ladder table ของ [migration-guide §2](./docs/migration-guide.md) + เขียน per-version doc (what/why + prereq + gotcha ที่เจอจริง)
4. เพิ่ม entry ใน [CHANGELOG.md](./CHANGELOG.md)
5. archive README เก่า → `README_v1_<prev>.md` (snapshot) · README ปัจจุบัน = รุ่นใหม่เสมอ

**PATCH (ไม่เปลี่ยนโครง · แค่แก้ generic infra/tooling · เช่น 1.5.1 → 1.5.2):**
1. bump SSOT → `1.5.2`
2. แก้ไฟล์ template ที่ต้องการ · ถ้าเพิ่มไฟล์ generic ใหม่ → เพิ่ม path เข้า manifest ของ `lib/sync-infra.sh`
3. เขียน `migrate/migration-v1.5.2.sh` ที่ **เรียก `lib/sync-infra.sh`** (ดู `migration-v1.5.1.sh` เป็นแบบ)
4. เพิ่ม entry ใน CHANGELOG

> **`lib/sync-infra.sh` sync อะไร** (generator-owned · tokenless): node-app `.dockerignore` · `Dockerfile.verify-backend` · `Dockerfile.verify-nx-backend` · `tools/` (recursive) · git-root `.gitattributes` · `.editorconfig` · `WORKSPACE.md` ·
> **ไม่แตะ** (workspace แก้เอง/มี token): `README.md` (ของโปรเจกต์ · seed ครั้งเดียวตอน create) · `.gitignore` · `nx.json` · `tsconfig.base.json` · `pnpm-workspace.yaml` · `package.json` · `Makefile`

### 3.4 ทดสอบ migration ก่อนออก

- **syntax:** `bash -n migration-v*.sh` · `node --check migration-v*.mjs`
- **driver ตรรกะ (ไม่ต้องรัน migration จริง):** copy `apply-migration.sh` ไปโฟลเดอร์ชั่วคราว + ใส่ stub `migration-v*.sh` (echo/exit) ชี้ที่ fake workspace (มีแค่ `workspaces/node-app/pnpm-workspace.yaml`) → ตรวจ ordered run · `--to` · `--list` · `--dry-run` · fail→retry · `--rerun` · idempotent
- **บน workspace จริง:** `apply-migration.sh <ws> --dry-run` และ `--list` (read-only) · แล้วรันจริงบน **branch** ของ workspace แล้วดู `git diff`

### 3.5 Release checklist (ออกเวอร์ชัน)

1. ☐ bump SSOT (`template/workspace/package.json` version)
2. ☐ เขียน `migration-v<semver>` + ผ่าน [test §3.4](#34-ทดสอบ-migration-ก่อนออก)
3. ☐ อัป CHANGELOG + (ถ้า minor) ladder table + per-version doc + archive README
4. ☐ commit ทุก repo ที่เกี่ยวข้อง (generator + demo/reference workspace ที่ต้อง regen)
5. ☐ **maintainer:** merge → `git tag v<semver>` ทั้ง generator + reference workspace → push `--tags`

> invariant ที่ทำให้ chain ได้: **ordered + additive + idempotent + version-marker** — อย่าเขียน migration ที่ต้องรันครั้งเดียว หรือรื้อของรุ่นก่อน
