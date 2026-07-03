# Migration Guide — อัป workspace เดิมขึ้น version ล่าสุด

## 🚀 เริ่มที่นี่ (สำหรับ user)

**คำสั่งเดียวจบ** — `apply-migration.sh` (driver) จะเช็คเองว่า workspace อยู่เวอร์ชันไหน แล้วรัน migration ที่ยังค้าง
**ตามลำดับ** จนถึงล่าสุด + อัป `template-version` + เขียน log ให้อัตโนมัติ (แนวเดียวกับ liquibase):

```bash
# <ws>  = โฟลเดอร์ workspace ของคุณ (ตัวที่มี workspaces/node-app)
# <gen> = โฟลเดอร์ workspace-generator
cd <ws> && git switch -c chore/update-workspace          # branch กันพลาด (workspace เป็น git อยู่แล้ว)

bash <gen>/script-generator/migrate/apply-migration.sh <ws> --list      # ① ดูว่าอยู่เวอร์ชันไหน + มีอะไรค้าง
bash <gen>/script-generator/migrate/apply-migration.sh <ws> --dry-run   # ② ดูแผนว่าจะรันอะไรบ้าง (ไม่แตะจริง)
bash <gen>/script-generator/migrate/apply-migration.sh <ws>             # ③ รันจริง (ไล่ทุก version ที่ค้าง)

git diff        # ④ ดู diff ให้พอใจ แล้วค่อย commit / merge
```

**แค่นั้น** — ไม่ต้องรู้ว่าต้องรันไฟล์ไหน ลำดับไหน · driver จัดให้หมด

**ระบุปลายทางเองก็ได้ (`--to`):**

| คำสั่ง | ไปถึงไหน |
|---|---|
| `apply-migration.sh <ws>` | **ล่าสุดสุด** ที่มี |
| `apply-migration.sh <ws> --to 1.5` | **1.5 patch ล่าสุด** (ไล่ 1.5.x ให้หมด · ไม่ข้ามไป 1.6) |
| `apply-migration.sh <ws> --to 1.5.0` | **หยุดเป๊ะที่ 1.5.0** (ไม่เอา 1.5.1) |

> กฎ `--to`: ใส่ครบ 3 หลัก (`1.5.0`) = หยุดเป๊ะ · ใส่ 2 หลัก (`1.5`) = patch ล่าสุดของ minor นั้น · ไม่ใส่ = ล่าสุดสุด

**คุณสมบัติที่ทำให้ปลอดภัย:**
- **รันซ้ำได้เสมอ** — driver รันเฉพาะ version ที่ **สูงกว่า** ปัจจุบัน → รันซ้ำ = "ไม่มีอะไรค้าง" (ไม่มีวัน downgrade)
- **พังแล้วรันซ้ำได้เลย** — migration ที่พัง **ไม่ bump version** → รอบหน้ารันมันซ้ำให้เอง (retry อัตโนมัติ · migration เป็น idempotent จะ skip step ที่ทำไปแล้ว) — ดู [§3](#3-เมื่อ-migration-พัง)
- **ย้อนได้** — workspace เป็น git → `git checkout -- <file>`

---

## 1) โมเดล (มองภาพรวม)

```
migrate/
  apply-migration.sh       ← ★ driver: เช็ค version → รัน pending ตามลำดับ + bump template-version + เขียน log
  migration-v1.4.0.mjs     ← export-strategy    (dev-condition exports)
  migration-v1.5.0.sh      ← backend-test-infra (make api-test, contract SSOT)
  migration-v1.5.1.sh      ← re-sync generic infra (verify Dockerfiles + tools/ + conventions)
  lib/
    sync-infra.sh          ← utility (copy generic files) — migration ไหน "อยากได้" ก็เรียกเอง
```

- **ทุก version (minor และ patch) = 1 ไฟล์ `migration-v<semver>.{sh,mjs}`** — ชื่อบอก version ปลายทาง
- **หน้าที่แยกชัด:** `apply-migration.sh` = ลำดับ + version marker + log · `migration-v*` = "งาน" · `lib/sync-infra.sh` = copy ไฟล์ (utility ล้วน · ไม่ยุ่ง version/log)
- **version marker** = `workspaces/node-app/template-version` (`<major>.<minor>.<patch>` · driver เป็นคนเขียน)
- **invariant:** ordered + additive + idempotent + version-marker → user ที่อยู่ 1.4 ตอนเราออก 1.8 = รันคำสั่งเดียว ไล่ 1.5→1.6→1.7→1.8 ให้เอง

---

## 2) Migration Ladder (มี migration อะไรบ้าง)

| version | migration file | เพิ่มอะไร | doc |
|---|---|---|---|
| **→ 1.4.0** | `migration-v1.4.0.mjs` | dual-condition exports (lint/test/build ไม่ต้อง build local dep ก่อน) | [export-strategy.md](./export-strategy.md) |
| **→ 1.5.0** | `migration-v1.5.0.sh` | backend-test + infrastructure layer (`make api-test`, contract SSOT) | [backend-test-migration.md](./backend-test-migration.md) |
| **→ 1.5.1** | `migration-v1.5.1.sh` | re-sync generic infra (verify Dockerfiles + `tools/` + conventions) | (นี่ = แค่เรียก `lib/sync-infra.sh`) |
| **→ 1.5.2** | `migration-v1.5.2.sh` | ship `WORKSPACE.md` (operational cheat sheet + ลิงก์ Developer Handbook) · **force-sync ผ่าน `lib/sync-infra`** (generator-owned · ไม่ชน README ของโปรเจกต์) | — |
| _→ 1.6.0_ | _(ออกเมื่อมีรุ่นใหม่ — เพิ่มไฟล์ `migration-v1.6.0.sh`)_ | — | — |

> driver ค้นไฟล์ `migration-v*` เอง เรียงด้วย semver — **เพิ่มไฟล์ = เพิ่ม rung** (ไม่ต้องแก้ driver)

**verify หลัง migrate (ตาม version ที่ถึง):**
```bash
cd <ws>/workspaces/node-app && pnpm install --no-frozen-lockfile   # + prisma:generate (1.5+)
cd ../backend-test && pnpm install                                 # (1.5+)
make api-test                                                      # (1.5+) หรือ lint/test/build (1.4)
```

---

## 3) เมื่อ migration พัง

driver จะ **หยุดทันที** ที่ตัวที่พัง · **ไม่ bump `template-version`** (ค้างที่ version ก่อนหน้า) · exit ≠ 0

```
>> migration → v1.6.0   (1.5.1 -> 1.6.0)   [migration-v1.6.0.sh]
   [FAIL] log: workspace-history/migration-history/0004-v1.6.0-....log
!! หยุดที่ v1.6.0 — แก้ต้นเหตุ (ดู log) แล้วรัน apply-migration ซ้ำได้ (retry อัตโนมัติ)
```

**วิธีแก้:**
1. เปิด detail log (path อยู่ในข้อความ) → ดู error เต็ม ๆ
2. แก้ต้นเหตุ (เช่น ลง dependency ที่ขาด)
3. **รัน `apply-migration.sh <ws>` เดิมซ้ำ** → เพราะ version ยังไม่เขยิบ → driver รัน migration ที่ค้างนั้นซ้ำให้เอง (ไม่ต้องใส่ flag)

ทุก attempt (fail + success) มี log แยกไฟล์ (คนละ seq/เวลา) → เห็นครบว่าพังกี่ครั้ง เพราะอะไร แล้วผ่านตอนไหน

---

## 4) Migration log (audit trail)

driver เขียน log ทุก run ที่ `workspaces/node-app/workspace-history/migration-history/` (commit เข้า git ได้ · ติดไปกับ repo):

```
workspaces/node-app/
  template-version                            # marker ปัจจุบัน (root)
  workspace-history/                          # ร่มใหญ่ (เผื่อของอื่นในอนาคต)
    migration-history/
      index.log                               # สรุป 1 บรรทัด/run (สแกนเร็ว)
      0001-v1.4.0-<ts>.log                    # รายละเอียดเต็มต่อ run (context + output + status)
      0002-v1.5.0-<ts>.log
```

`index.log`:
```
# seq | timestamp | from -> to | migration | status | gen | detail
0001 | 2026-07-03T10:15:03+0700 | 0.0.0 -> 1.4.0 | migration-v1.4.0.mjs | OK   | 9d5d003 | 0001-v1.4.0-....log
0002 | 2026-07-03T10:15:07+0700 | 1.4.0 -> 1.5.0 | migration-v1.5.0.sh  | OK   | 9d5d003 | 0002-v1.5.0-....log
```

- `gen=<sha>` = git commit ของ generator ที่ใช้รัน (สำคัญตอน debug)
- `--rerun <ver>` = บังคับรัน version ที่ **applied แล้ว** ซ้ำ (เช่น migration idempotent อยากลงใหม่) → เพิ่ม log entry ใหม่ · ไม่ downgrade version

---

## 5) รันตรง / utility (advanced)

ปกติใช้ `apply-migration.sh` พอ — แต่รัน migration/utility ตรง ๆ ก็ได้ (ไม่ผ่าน driver = **ไม่ bump version / ไม่เขียน log**):

```bash
# รัน migration เดี่ยว (auto-derive args เอง)
bash migration-v1.5.0.sh <ws>
node migration-v1.4.0.mjs <ws>

# sync generic infra อย่างเดียว (ไฟล์เครื่องมือ/Dockerfile ให้ตรง template · ไม่แตะ version)
bash lib/sync-infra.sh <ws> --dry-run   # ดูก่อน
bash lib/sync-infra.sh <ws>             # จริง
```

**`lib/sync-infra.sh` sync อะไร (generator-owned · tokenless):**

| sync (เขียนทับได้) | node-app: `.dockerignore` · `Dockerfile.verify-backend` · `Dockerfile.verify-nx-backend` · `tools/` (recursive) · root: `.gitattributes` · `.editorconfig` |
|---|---|
| **ไม่แตะ** (workspace แก้เอง / มี token) | `.gitignore` · `tsup.lib.config.ts` · `nx.json` · `tsconfig.base.json` · `pnpm-workspace.yaml` · `package.json` · `Makefile` |

- **ไม่ลบไฟล์** — ไฟล์ที่ workspace มีแต่ template ไม่มี = `! orphan (เก็บไว้)` เตือนเฉย ๆ
- **idempotent** — รันซ้ำ = `+0 ~0`

---

## 6) สำหรับ contributor — เพิ่ม migration / ออก version ใหม่

การเพิ่ม `migration-v<semver>`, migration contract, version SSOT, release checklist และการทดสอบ migration →
ดู **[CONTRIBUTING.md §3 (Migration & versioning)](../CONTRIBUTING.md#3-migration--versioning-สำคัญ)**

---

## ดูต่อ

- README ปัจจุบัน (รุ่นล่าสุด): [README.md](../README.md) · เก่า: [README_v1_4.md](../README_v1_4.md) · [README_v1_3.md](../README_v1_3.md)
- per-version: [export-strategy.md](./export-strategy.md) (→1.4) · [backend-test-migration.md](./backend-test-migration.md) (→1.5)
