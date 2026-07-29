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
