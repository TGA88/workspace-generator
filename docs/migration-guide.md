# Migration Guide — อัป workspace เดิมขึ้น version ล่าสุด

workspace ที่ scaffold ด้วย generator รุ่นเก่า **อัปขึ้นรุ่นล่าสุดได้แบบเป็นขั้น** โดยไม่ต้อง re-generate ใหม่
เพราะ migration แต่ละรุ่นถูกออกแบบให้:

- **ordered + additive** — แต่ละรุ่นเพิ่ม "layer" ต่อยอด ไม่รื้อของเดิม
- **idempotent** — รันซ้ำได้ไม่พัง (guard ด้วย check ก่อนแก้ทุกจุด) → ถ้าไม่แน่ใจว่าอยู่รุ่นไหน รันตั้งแต่ต้น ladder ได้เลย ตัวที่ทำแล้วจะ skip เอง
- **version marker** — บันทึกจุดปัจจุบันไว้ที่ `workspaces/node-app/template-version`

> ผลลัพธ์: user ที่อยู่ **1.4** ในขณะที่เราออก **1.8** แล้ว = รัน migration ของรุ่น 1.5 → 1.6 → 1.7 → 1.8 **ตามลำดับ** ก็ขึ้นถึงล่าสุดได้

---

## 1) เช็ค version ปัจจุบันของ workspace

```bash
cat workspaces/node-app/template-version    # เช่น 1.4.0
```
- **ไม่มีไฟล์นี้ / อ่านไม่ได้** → workspace สร้างก่อน 1.3.x หรือยังไม่เคยรัน `update-workspace-config.sh` → ถือว่า **< 1.4** (เริ่มจากต้น ladder)
- migration script จะ **bump ค่านี้ให้เอง** เมื่อผ่านแต่ละขั้น

---

## 2) Migration Ladder (รันจาก version ปัจจุบัน → ล่าสุด ตามลำดับ)

| from → to | script (ใน `script-generator/migrate/`) | เพิ่มอะไร | idempotent | doc |
|---|---|---|---|---|
| **< 1.4 → 1.4** | `node apply-export-strategy.mjs <ws>/workspaces/node-app` | dual-condition exports (lint/test/build ไม่ต้อง build local dep ก่อน) | ✅ | [export-strategy.md](./export-strategy.md) |
| **1.4 → 1.5** | `bash apply-backend-test-infra.sh <ws> [SERVICE] [DB_SCHEMA]` | backend-test + infrastructure layer (`make api-test`, contract SSOT) | ✅ | [backend-test-migration.md](./backend-test-migration.md) |
| _1.5 → 1.6_ | _(ออกเมื่อมีรุ่นใหม่ — เพิ่มแถวที่นี่)_ | — | — | — |

> `<ws>` = git root ของ workspace เป้าหมาย (มี `workspaces/node-app`) · path ของ script เต็ม = `workspace-generator/script-generator/migrate/<script>`

---

## 3) วิธีทำ (ข้ามหลาย version)

```bash
# ตัวอย่าง: workspace อยู่ 1.4 → อยากขึ้นล่าสุด (สมมติ 1.5)
cd <ws>

# (0) branch ไว้กันพลาด + ให้ตรวจ diff ได้
git switch -c chore/migrate-to-latest

# (1) รันทีละ rung จาก current+1 → target ตามลำดับใน ladder ข้อ 2
#     ถ้าไม่แน่ใจว่าอยู่รุ่นไหน เริ่มจาก rung แรกที่ต่ำกว่า/เท่ากับ version ปัจจุบันได้เลย (idempotent จะ skip)
bash workspace-generator/script-generator/migrate/apply-backend-test-infra.sh <ws>

# (2) ตรวจ diff แต่ละขั้น + prereq ของรุ่นนั้น (ดู doc ต่อรุ่น) แล้ว commit
git add -A && git commit -m "chore: migrate workspace 1.4 -> 1.5"

# (3) verify ตาม version ล่าสุดที่ถึง
cd workspaces/node-app && pnpm install --no-frozen-lockfile   # + prisma:generate ถ้าถึง 1.5
cd ../backend-test && pnpm install                            # (1.5+)
make api-test                                                 # (1.5+) หรือ lint/test/build (1.4)
```

**กฎ:**
1. **รันตามลำดับ** — 1.4 ก่อน 1.5 ก่อน 1.6 … (rung หลังพึ่ง semantics ของ rung ก่อน · เช่น backend-test-infra ต้องการ export-strategy มาก่อน)
2. **commit ทีละขั้น** — ตรวจ diff + verify แต่ละรุ่นก่อนไปต่อ (ถ้าพังจะรู้ว่าตกที่รุ่นไหน)
3. **idempotent = ปลอดภัย** — รัน script เดิมซ้ำได้ (ทำแล้ว skip) → ไม่ต้องกลัวว่ารันเกิน

---

## 4) สำหรับ generator dev — เพิ่ม rung ใหม่ตอนออก version

ทุกครั้งที่ออก version ใหม่ที่ **เปลี่ยนโครง scaffold** ให้ทำครบชุดนี้ เพื่อให้ ladder ต่อเนื่อง:

1. เขียน `script-generator/migrate/apply-<feature>.{sh|mjs}` — **idempotent** (check ก่อนแก้ทุกจุด), upgrade จากรุ่นก่อนหน้า, **bump `template-version`** ท้ายสุด
2. เพิ่ม 1 แถวใน **ladder table** (ข้อ 2) + link doc รายละเอียดของรุ่น
3. bump `template/workspace/package.json` `"version"` เป็นรุ่นใหม่
4. **archive README เก่า** → `README_v1_<prev>.md` (snapshot จาก branch-point) · README ปัจจุบัน = รุ่นใหม่เสมอ · อัปเดต pointer "README ฉบับก่อนหน้า"
5. เขียน per-version migration doc (เช่น [backend-test-migration.md](./backend-test-migration.md)) — what/why + prereq + gotcha ที่เจอจริง

> invariant ที่ทำให้ chain ได้: **ordered + additive + idempotent + version-marker** — อย่าทำ migration ที่ต้องรันครั้งเดียว หรือรื้อของรุ่นก่อน

---

## ดูต่อ

- README ปัจจุบัน (รุ่นล่าสุด): [README.md](../README.md) · เก่า: [README_v1_4.md](../README_v1_4.md) · [README_v1_3.md](../README_v1_3.md)
- per-version: [export-strategy.md](./export-strategy.md) (→1.4) · [backend-test-migration.md](./backend-test-migration.md) (→1.5)
