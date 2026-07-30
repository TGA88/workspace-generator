# Migration → v1.7.0 — web scaffold mode (standalone | static)

> TL;DR: **workspace เดิมไม่ต้องทำอะไร** (migration = no-op) · ของใหม่มีผลกับ **แอปที่ gen หลังจากนี้** เท่านั้น

## What

`new-web.sh` รับ **deploy mode** เป็น argument ที่ 4:

```bash
new-web.sh <workspace-dir> <project-name> [generator-dir] [standalone|static]
```

| | default | `standalone` | `static` |
|---|---|---|---|
| `next.config.mjs` | = standalone | `output:'standalone'` | `output:'export'` + `distDir` + `trailingSlash` |
| `middleware.ts` | มี | มี | **ไม่มี** (ไม่มี server runtime ให้เรียก) |
| `app/[locale]/layout.tsx` | server messages | `getMessages()` | static messages map + `generateStaticParams()` |
| `app/(public)/layout.tsx` | server messages | `getMessages()` | static messages map |
| `i18n/request.ts` | requestLocale | `requestLocale` (อ่าน headers) | default locale คงที่ |
| `messages/index.ts` | — | — | **มี** (bundle ทุก locale ตอน build) |

**ไม่ระบุ = `standalone`** → พฤติกรรมเหมือน v1.6.x ทุกประการ

## Why

`output:'export'` ไม่มี request context ⇒ `getMessages()` · `cookies()` · `requestLocale` ใช้ไม่ได้ทั้งหมด
การเปลี่ยน mode จึงเปลี่ยน **4 ไฟล์พร้อมกัน** ไม่ใช่แค่ `next.config.mjs`

เดิม template ทิ้ง `next-config-mjs-static` / `next-config-mjs-standalone` ไว้ให้ผู้ใช้ copy เอง —
นั่นแก้ให้แค่ **1 ใน 4 ไฟล์** ⇒ ผู้ใช้ยังต้องไปไล่แก้ layout/i18n เองอยู่ดี และถ้าลืม
`next build` จะพังหรือได้ผลลัพธ์ผิดโดยไม่มีอะไรเตือน

หลักฐานจากสนาม: auth-portal ต้องทำ conversion ชุดนี้ด้วยมือ **2 ครั้ง** — `portal-web` (P-PW.0)
และ `admin-portal-web` (P-PW.5c) — ชุดแก้เหมือนกันเป๊ะทั้ง 2 รอบ

## Prereq

ไม่มี — no-op

## Gotcha

- **mode อยู่ที่ `$4` ไม่ใช่ `$3`** — `$3` เป็น `GENERATOR_DIR` มาแต่เดิม การแทรก mode ตรงนั้น
  จะทำให้ caller เก่าส่ง generator-dir ไปตกที่ mode แล้ว fail ทันที (เจตนา: ของเก่าต้องรันได้เหมือนเดิม)
- mode ที่พิมพ์ผิด → **fail พร้อม usage (exit 1)** ไม่ใช่ fallback เงียบ ๆ ไป standalone
- **แอปที่แปลง static ด้วยมือไปแล้วก่อน v1.7.0 ยังถูกต้อง** — v1.7.0 ไม่ย้อนไปแก้อะไร แค่ทำให้
  แอปตัวถัดไปไม่ต้องทำซ้ำ
- `basePath` (กรณีเสิร์ฟ SPA ใต้ path prefix เช่น `/admin`) **ยังต้องตั้งเอง** — เป็น topology
  ของแต่ละ deployment ไม่ใช่ของ mode · ⚠️ ตอนตั้ง `basePath` ไฟล์ที่ export **ไม่ได้ย้ายตาม prefix**
  (URL มี prefix แต่ไฟล์อยู่ที่รากของ `distDir`) → ฝั่ง web server ต้อง map ให้ตรง เช่น mount
  export ไว้ที่ `<docroot>/<prefix>` (auth-portal ทำแบบนี้กับ nginx ใน P-PW.5c)

## Verify

รัน gen ทั้ง 2 mode บน workspace ทิ้ง แล้วเทียบ:

```bash
new-web.sh ws demo-a-web <gen> static
new-web.sh ws demo-b-web <gen>            # default = standalone
```

- `static` → `next.config.mjs` มี `output: 'export'` · **ไม่มี** `middleware.ts` · **มี** `messages/index.ts`
- `standalone` → `output: 'standalone'` · **มี** `middleware.ts` · **ไม่มี** `messages/index.ts`
- ทั้งคู่ → **มี `.gitignore`** (v1.7.0 แก้ `cp -r nextjs/*` ที่ทำ dotfile หาย) และ**ไม่มี**
  `next-config-mjs-*` ค้าง

---

# ▶ v1.7.1 — storybook host scope + verify OOM knob

> TL;DR: **มีของต้องทำจริง** (ต่างจาก 1.7.0 ที่ no-op) — migration sync tool 2 ตัว + เติม flag ใน
> `Dockerfile.verify-*` · หลัง migrate ต้องรัน `pnpm update:storybook_alias` ที่ host แต่ละตัวเอง

## What

**1. storybook host ครอบเฉพาะ lib ของ base ตัวเอง**

| | ก่อน 1.7.1 | 1.7.1 |
|---|---|---|
| `stories` ที่ scaffold ออกมา | `libs/**/feature-*/…` (ทุก base) | `libs/<lib-scope>/**/feature-*/…` |
| `new-storybook.sh` | `<ws> <host> [gen-dir]` | `<ws> <host> [gen-dir] **[lib-scope]**` · default `<host>-lib` |
| `update_storybookhost_alias.sh` สแกนที่ไหน | `libs/` ทั้งก้อน (**ไม่เคยใช้ `$2`**) | root ที่ derive จาก **`stories` ของ host เอง** |
| alias ข้าม base ที่เคยถูกเขียนไว้ | ค้างตลอด (`grep -v feature-` เก็บ `@ui-*` ไว้) | ถูกล้างออกตอนรันรอบถัดไป |

**2. `update_alias_path.sh` เลิกลบ alias ที่ template เป็นเจ้าของ** — `@` / `@root` (และ alias อื่นที่
ไม่ใช่ sub-module) รอดข้ามรอบแล้ว · ส่วน `@feature-*` / `@ui-*` ที่ไม่มี dir จริงแล้วยังถูกล้างเหมือนเดิม

**3. `--workspace-concurrency=1` ใน `Dockerfile.verify-*`** — กัน OOM (exit 137) ที่อ่านเหมือน "เทสตก"

## Why

`stories` glob กับ alias เป็น **2 กลไกที่ต้องพูดตรงกัน** แต่เดิมมาจากคนละที่: glob มาจาก template ·
alias มาจาก `find libs/` ⇒ พอมี base ที่ 2 host ของ base ใหม่ได้ทั้ง story และ alias ของ base เก่า

หลักฐานจากสนาม: auth-portal (P-PW.5d-1) — `libs/admin-portal-lib` **ว่างเปล่า** แต่ `test-storybook`
ของ host `admin-portal` **เขียว** เพราะรัน story ของ `portal-lib` · แก้ glob ในรีโปแล้วก็ยังโดน
`update:storybook_alias` เขียน alias ข้าม base กลับมาทุกครั้ง เพราะ `tools/` = generator-owned

⇒ 1.7.1 ให้ **`stories` เป็น SSOT** แล้ว alias อ่านจากตรงนั้น — แก้ที่เดียว ทั้งคู่ตรงกันเสมอ
(เกณฑ์วัดจาก "host ประกาศว่าครอบอะไร" ไม่ใช่ proxy อย่างชื่อโฟลเดอร์)

## Prereq

ไม่มี — migration idempotent รันซ้ำได้

## Gotcha

- **`lib-scope` อยู่ที่ `$4`** (เหมือน mode ของ `new-web.sh`) — `$3` = `GENERATOR_DIR` มาแต่เดิม
- **default = `<host>-lib`** · workspace ที่ lib อยู่ที่อื่น (เช่น `shared-web` ซึ่งเป็น default ของ
  `new-frontend-lib-modules.sh`) ต้องส่ง `$4` เอง: `new-storybook.sh <ws> example "" shared-web`
- **host เก่าที่ `stories` ยังเป็น `libs/**` = ได้พฤติกรรมเดิมเป๊ะ** (host ประกาศว่าครอบทุก base) —
  migration จะ**รายงาน**ให้ แต่ไม่แก้ไฟล์ให้ เพราะ "ครอบทุก base" อาจเป็นเจตนาจริงของบาง workspace
- **migration ไม่รัน `pnpm update:storybook_alias` ให้** (ต้องใช้ npx/prettier ของ workspace) →
  alias ข้าม base ที่เขียนไว้แล้วจะหายก็ต่อเมื่อรันเอง
- **ไม่เรียก `lib/sync-infra.sh`** — มันจะ copy `Dockerfile.verify-backend` ทับทั้งไฟล์ แล้วลบ
  deviation ของ adopter (auth-portal แยก fe/be เป็น `Dockerfile.verify-frontend` ซึ่ง template ยังไม่มี)
  ⇒ ตัวนี้ patch เฉพาะ flag บรรทัดที่ต้องเติม
- ⚠️ **หนี้ที่ยังเหลือ**: ใครเรียก `sync-infra` ตรง ๆ ก็ยังทับ `Dockerfile.verify-backend` อยู่ดี ·
  fe/be split เข้า template = คุยแยก (template ยังไม่มี frontend arm มาตรฐาน)
- `Dockerfile.verify-nx-backend` — lint/test วิ่งผ่าน nx run-many ⇒ ปุ่มลดความขนานคือ `nx --parallel`
  **ไม่ใช่** `pnpm --workspace-concurrency` · 1.7.1 เติมให้เฉพาะ step ที่เป็น pnpm recursive จริง

## Verify

```bash
bash script-generator/migrate/apply-migration.sh <ws> --to 1.7.1
```

- `tools/update_storybookhost_alias.sh` + `tools/update_alias_path.sh` = ตรง template
- `Dockerfile.verify-*` → `grep -c 'workspace-concurrency=1'` > 0 · **บรรทัดอื่นไม่ขยับ** (`git diff`)
- รัน migration ซ้ำ → `= unchanged` / `= ok` ทุกช่อง (idempotent)
- scaffold host ใหม่ 2 base แล้วเทียบ: `storybook-host/<a>` ต้อง**ไม่มี** alias ของ base `<b>`
