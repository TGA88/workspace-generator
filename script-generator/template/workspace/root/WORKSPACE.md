# Workspace — วิธีใช้ & รัน (Getting Started)

pnpm + Nx monorepo · backend (Fastify + Prisma) · frontend (Next.js / Storybook) · black-box API testing
scaffold ด้วย **[workspace-generator](https://bebestdev.com/developer-handbook/readme.html)**

> **เพิ่ง clone มา? เริ่มที่นี่.** เอกสารนี้ = **วิธีรัน** (คำสั่ง + เครื่องมือที่ workspace มีให้) ·
> ส่วน **สถาปัตยกรรม + วิธีเขียนโค้ดต่อ layer + วิธีเขียน test** อยู่ใน 📘 **[Developer Handbook](https://bebestdev.com/developer-handbook/)**
>
> ⚙️ ไฟล์นี้ **generator ดูแล** (force-sync ตอน migrate — อย่าแก้มือ เดี๋ยวโดนเขียนทับ) · ส่วน `README.md` = ของโปรเจกต์ (แก้ได้)

## 🧭 หาอะไรอยู่?

| อยากรู้ | ไปที่ |
|---|---|
| เข้าใจโครง · เขียนโค้ดต่อ layer · methodology / วิธีเขียน contract & test | 📘 [Developer Handbook](https://bebestdev.com/developer-handbook/) |
| **รัน test · dev · คำสั่ง** (operational) | เอกสารนี้ ↓ |
| เพิ่ม API endpoint (scaffolding) | `pnpm gen:api-*` (§3) |
| อัป workspace เป็นเวอร์ชันใหม่ | §4 (migration) |

## 1) Setup (ครั้งแรกหลัง clone)

```bash
cd workspaces/node-app && pnpm install      # store-prisma postinstall → prisma generate
# ถ้า prisma client ไม่ถูก generate: pnpm -r --if-present run prisma:generate
cd ../backend-test && pnpm install          # test harness (standalone package · นอก pnpm workspace)
```
> ต้องมี **Docker** running สำหรับ `make api-test` (ยก DB + API จริง)

## 2) รัน test — workspace มี "เครื่อง" พร้อม (`make`, รันจาก git root)

```bash
make api-test           # black-box: compose ยก DB+API จริง → ยิง HTTP (contract + assertDb) → down -v
                        #   เจาะจง: make api-test DOMAIN=<d>-api ACTION=<verb>-<d>
make verify-backend     # in-container: lint + tsc + unit test (ไม่ต้องมี DB)   [pnpm --filter]
make verify-nx-backend  # เหมือนบน แต่ใช้ nx run-many
make test               # host node:test เร็ว (ต้อง make api-up ให้ stack ขึ้นก่อน)
make help               # ดู target + ตัวแปรทั้งหมด
```

| อยากได้ | ใช้ |
|---|---|
| ยืนยันทั้ง flow (local == CI) | `make api-test` |
| เช็ค lint/type/unit เร็ว ไม่ยุ่ง DB | `make verify-backend` |
| iterate เร็วตอน dev (stack ขึ้นแล้ว) | `make api-up` → `make test` |

> ⚙️ workspace-generator สร้าง `root/Makefile` + `workspaces/infrastructure/` + `workspaces/backend-test/` ให้ = **เครื่องมือสำหรับรัน api-test ตามที่ handbook สอน** ·
> **วิธีเขียน contract & test (methodology) → 📘 handbook › Backend Testing / Backend Test & Infra**

## 3) เพิ่ม API (scaffolding) — ต้องมี workspace-generator เป็น sibling

`pnpm gen:api-*` ต้องมี `workspace-generator/` วางระดับเดียวกับ workspace (หรือ set `WORKSPACE_GENERATOR_DIR`) — ใช้เฉพาะตอน scaffold (ไม่เกี่ยวกับ build/test/run รายวัน)

```bash
pnpm gen:api-domain   <scope> <api-pkg> <domain>                      # core+service+client ของ domain
pnpm gen:api-wire     <scope> <api-pkg> <data-pkg> <webapi> <domain>  # + prisma repo + route + model
pnpm gen:api-action   <scope> <api-pkg> <domain> <command|query> <verb>
pnpm gen:api-contract <service> <domain> [action]                    # contract ⇄ backend-test pair
```
> รายละเอียด scaffolding → 📘 handbook › API Scaffolding (User Guide)

## 4) อัป workspace (migration)

```bash
GEN=../workspace-generator/script-generator/migrate   # ปรับ path ให้ตรง sibling ของคุณ
bash $GEN/apply-migration.sh . --list      # อยู่เวอร์ชันไหน + ค้างอะไร
bash $GEN/apply-migration.sh . --dry-run   # ดูแผน (ไม่แตะจริง)
bash $GEN/apply-migration.sh .             # รันจริง (ไล่ทุกเวอร์ชันที่ค้าง)
```
> เวอร์ชันปัจจุบัน: `cat workspaces/node-app/template-version` · log: `workspaces/node-app/workspace-history/`

## 5) Frontend dev

```bash
pnpm --filter <storybook-host> storybook   # พัฒนา component (Storybook)
pnpm --filter <web-app> serve              # หน้า (Next.js)
```
> workflow เต็ม → 📘 handbook › Frontend Dev Workflow / Feature Playbook

---
🔧 scaffold + migrate ด้วย **workspace-generator** · 📘 คู่มือนักพัฒนา: **https://bebestdev.com/developer-handbook/**
