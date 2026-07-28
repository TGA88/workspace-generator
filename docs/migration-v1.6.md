# Migration → v1.6.0

> รัน: `bash script-generator/migrate/apply-migration.sh <ws>` (driver ไล่ rung ให้เอง · ดู [migration-guide](./migration-guide.md))
> ทำบน **branch ของ workspace** แล้วดู `git diff` ก่อน merge

## รุ่นนี้มีอะไร

**1.6.0 = frontend loop alignment (harvest จาก auth-portal) + `packages/` taxonomy**

- โครง frontend lib ตาม developer-handbook `frontend-structure §3` — `feature-<name>/{pages,components,hooks,logic,types,mocks,main.ts}` (เลิก `containers/` + `functions/`)
- **exports convention ของ frontend lib** — `.` + exact entry `./feature-<name>` ต่อ sub-module · consumer import `@scope/<lib>/feature-<name>` (ไม่ต้องต่อ `/main`)
- **tool ใหม่ `generate-exports-web.sh`** — `pnpm gen:exports` ของ frontend lib ต้องชี้ตัวนี้ · ตัวเดิม `generate-exports.sh` = **backend-only**
- **`update_alias_path.sh` เขียนใหม่** (fix · ดู §3)
- **`packages/` taxonomy** — โฟลเดอร์ที่ 3 คู่ `apps/` + `libs/` สำหรับ lib ที่ publish ข้าม repo

---

## 1) อะไร "ถึง workspace เดิม" vs "เฉพาะ project ที่ generate ใหม่"

⚠️ **จุดที่คนเข้าใจผิดบ่อยที่สุดของรุ่นนี้** — migration แตะได้เฉพาะ tooling/infra ของ workspace เท่านั้น

| หมวด | ตัวอย่าง | ถึง workspace เดิมไหม |
|---|---|---|
| **tooling** (`tools/`) | `update_alias_path.sh` (แก้แล้ว) · `generate-exports-web.sh` (ใหม่) · `gen_front_skelton.sh` (โครงใหม่) | ✅ **ได้เลย** — force-sync ผ่าน `lib/sync-infra` |
| **workspace config** | `pnpm-workspace.yaml` (`packages/**`) · root globs 6 ตัว (`lint`/`test`/`build` × `frontend-libs`/`backend-libs`) | ✅ **ได้เลย** — migration patch ให้ (ดู §2) |
| **project template** | `feature-*/pages+logic` · `storybook-host` (test-runner) · `web-config` · webapi ที่ตัด `api-client/.gitkeep` | ❌ **เฉพาะ project ที่ generate ใหม่** |

**frontend lib เดิมที่อยากได้โครงใหม่ = ย้ายมือ** (ตั้งใจ — migration ห้ามแตะ app source ตาม [CONTRIBUTING §3.2](../CONTRIBUTING.md)) · ทำตาม handbook [`frontend-structure §3`](https://bebestdev.com/developer-handbook/frontend-structure.html) แล้วรัน 3 คำสั่งใน lib: `pnpm update:alias-paths` · `pnpm update:config` · `pnpm gen:exports`

---

## 2) ทำไม migration รุ่นนี้ patch ไฟล์เอง (ไม่ใช่แค่ `sync-infra`)

`lib/sync-infra.sh` **จงใจไม่แตะ** `pnpm-workspace.yaml` และ root `package.json` (เป็นของ workspace · มี token/ของที่ทีมแก้เอง) — แต่ `packages/` taxonomy อยู่ในสองไฟล์นั้นพอดี:

- `pnpm-workspace.yaml` → เพิ่ม `- 'packages/**'` (ถ้าไม่มี pnpm ไม่รู้จัก workspace ใหม่)
- root `package.json` → 6 script glob: frontend arm ได้ `packages/frontend/**` · backend arm ได้ `packages/backend/**`

⇒ ถ้าไม่ patch = upgrade แล้ว **`packages/` ใช้ไม่ได้จริง** (สร้างโฟลเดอร์ไปก็ไม่มีใครเห็น) · migration จึงแก้ให้ แบบ **idempotent + guard**: ทำไปแล้ว/รูปไม่ตรงที่คาด = ข้าม ไม่เดา (workspace ที่เคยเติมมือไว้แล้วรันซ้ำได้ปลอดภัย)

**เกณฑ์ว่าอะไรควรอยู่ไหน:** `publishConfig.access === 'public'` → `packages/{frontend,backend}/` · `restricted` → `libs/`

---

## 3) fix: `tools/update_alias_path.sh` เขียนใหม่ (สำคัญ)

**อาการของเดิม** — ตัวเก่าใช้ `sed` command `c\` แทนที่ *บรรทัด* ที่ match แล้วเดาขอบเขตบล็อก · พฤติกรรม BSD (macOS) กับ GNU sed ไม่เหมือนกัน ⇒ เจอจริง:

- `jest.config.ts` ได้ **`moduleNameMapper` ซ้ำ 2 บล็อก** → duplicate key = TS parse error ทันที
- `tsconfig.json` / `tsconfig.build.json` เสีย **key อื่นใน `compilerOptions`** (`types` · `moduleDetection` · `rootDir`) และวงเล็บปิดหาย

**ตัวใหม่** — แทนที่ *เฉพาะเนื้อในบล็อกเป้าหมาย* โดยไล่วงเล็บจริง (ข้าม string/comment) ⇒ comment · key อื่น · การจัดรูปนอกบล็อก ไม่ถูกแตะเลย · **fail-closed**: หาบล็อกไม่เจอหรือวงเล็บไม่สมดุล = ไม่แตะไฟล์ + บอกให้เติมบล็อกว่างเอง

**ถ้า workspace เคยโดนตัวเก่าทำพังไว้** — migration ไม่ย้อนแก้ให้ (แตะ tooling ไม่แตะ config ของ lib) → ซ่อมมือรอบเดียว: เอา `moduleNameMapper` ให้เหลือบล็อกเดียว (ตัวแรกต้อง spread `...(baseConfig.moduleNameMapper || {})`) · คืน key ที่หายใน `compilerOptions` แล้วรัน `pnpm update:alias-paths` ใหม่ (ตัวใหม่จะ idempotent ตั้งแต่นั้น)

---

## 4) หลัง migration

```bash
cd <ws>/workspaces/node-app
pnpm install --no-frozen-lockfile   # workspace glob เปลี่ยน
pnpm run lint:frontend-libs && pnpm run lint:backend-libs
pnpm run test:frontend-libs && pnpm run test:backend-libs
```

> glob `packages/**` ที่ยังไม่มีโฟลเดอร์จริง = **คืนศูนย์เงียบ ๆ ไม่ error** (พิสูจน์บน reference workspace แล้ว) — สร้าง `packages/{frontend,backend}/` เมื่อมีของจริงเท่านั้น

**ตรวจว่าขึ้นจริง:** `cat workspaces/node-app/template-version` → `1.6.0` · log อยู่ `workspaces/node-app/workspace-history/migration-history/`
