# Export Strategy & Build System (v1.4)

เอกสารนี้อธิบายว่า workspace ที่ generate ออกมาจัดการ `exports`, การ resolve module ตอน dev/build/runtime และการตั้งค่า nx/tsconfig/jest/tsup อย่างไร — เพื่อให้ **lint / test / build รันได้ทันทีโดยไม่ต้อง build local dependency ก่อน** แต่ production ยังใช้ `dist` ที่ optimize แล้วทุกประการ

> สรุปสั้นอยู่ใน [README](../README.md#export-strategy--build-system-v14) — ไฟล์นี้คือฉบับเต็ม

## สารบัญ

- [1. ปัญหาที่แก้](#1-ปัญหาที่แก้)
- [2. แนวคิด: Conditional Exports](#2-แนวคิด-conditional-exports)
- [3. customConditions (TypeScript) ทำงานอย่างไร](#3-customconditions-typescript-ทำงานอย่างไร)
- [4. เดินดูการ resolve ทีละขั้น](#4-เดินดูการ-resolve-ทีละขั้น)
- [5. การตั้งค่าครบทุกจุด](#5-การตั้งค่าครบทุกจุด)
- [6. Nx targets: ใครพึ่ง ^build บ้าง](#6-nx-targets-ใครพึ่ง-build-บ้าง)
- [7. กฎที่ต้องรักษา](#7-กฎที่ต้องรักษา)
- [8. Troubleshooting](#8-troubleshooting)
- [9. Migrate workspace เดิม](#9-migrate-workspace-เดิม)

---

## 1. ปัญหาที่แก้

ใน monorepo ที่ local package อ้างถึงกัน (เช่น `api-service` ใช้ `api-core`, `*-api` ใช้ `share-data`) ความต้องการ 2 ด้านขัดกัน:

- ตอน **dev**: อยากให้ resolve ไปที่ source ตรงๆ — แก้โค้ดใน core แล้ว service เห็นทันที, lint/test ไม่ต้องรอ build, jump-to-definition วิ่งไป `.ts` จริง
- ตอน **production / publish**: ต้องเป็น `dist` ที่ build แล้ว เพราะ Node รัน `.ts` ไม่ได้ และ consumer ที่ติดตั้งจาก registry ไม่ควรต้อง compile source ของเรา

ของเดิม (ก่อน v1.4) `exports` ชี้ไปที่ `dist` อย่างเดียว ผลคือ **ต้อง build dependency ก่อนเสมอ** ถึงจะ lint/test/build project ที่ใช้มันได้ ยิ่ง package เยอะยิ่งช้า

v1.4 แก้ด้วย **dual-condition exports**: ประกาศทั้งสองทางในไฟล์ `package.json` เดียว แล้วให้แต่ละเครื่องมือเลือกทางเองตาม "condition" ที่มันเปิด

---

## 2. แนวคิด: Conditional Exports

ตั้งแต่ Node 12 field `exports` เลือกไฟล์ปลายทางตาม "เงื่อนไข" (condition) ของผู้ที่มา import ได้:

```jsonc
// libs/.../shop-api/service/package.json
"exports": {
  "./command/*": {
    "development": "./src/command/*/index.ts",   // ① dev tooling ที่เปิด condition นี้
    "import":      "./dist/command/*/index.mjs",  // ② ใคร import (ESM) — runtime/release
    "require":     "./dist/command/*/index.js",   // ③ ใคร require (CJS)
    "types":       "./dist/command/*/index.d.ts"  // ④ ตัวอ่าน type ทั่วไป
  }
}
```

กติกา 2 ข้อ:

1. แต่ละ resolver มี "ชุด condition ที่เปิดอยู่" ของตัวเอง เช่น Node ตอน `import` เปิด `["node","import","default"]`
2. **resolver ไล่ key จากบนลงล่าง — condition แรกที่เปิดอยู่ชนะทันที แล้วหยุด** → ลำดับ key มีความหมาย `development` จึงต้องอยู่บนสุดเสมอ

`development` **ไม่ใช่ condition มาตรฐานของ Node** เป็นชื่อ custom ที่เราตั้งเองตาม convention ของ ecosystem (webpack/Vite เปิดให้อัตโนมัติเมื่ออยู่ใน dev mode) จุดที่ทำให้ปลอดภัย: **เครื่องมือที่ไม่เปิด condition นี้จะข้ามบรรทัดนั้นไปเหมือนไม่มีอยู่** — Node ตอน production ไม่เคยถูกสั่งให้เปิด `development` จึงเห็นแค่ `import`/`require` → ได้ `dist` เสมอ ไม่มีทางหลุดไปอ่าน `src`

นอกจากนี้ทุก lib ตั้ง `"sideEffects": false` เพื่อให้ bundler ฝั่ง consumer (Next.js / tsup ของ app) tree-shake action ที่ไม่ได้ใช้ออกได้

---

## 3. customConditions (TypeScript) ทำงานอย่างไร

ปกติ tsc resolve module โดยเปิดแค่ condition มาตรฐาน (`types`, `import`/`require`, `node`) จึงมองไม่เห็นบรรทัด `development`

TypeScript **5.0** (มี.ค. 2023) เพิ่ม option นี้เพื่อสั่งให้ tsc เปิด custom condition เพิ่ม:

```jsonc
// tsconfig.base.json
"compilerOptions": {
  "moduleResolution": "NodeNext",      // ต้องเป็น node16 / nodenext / bundler เท่านั้น
  "customConditions": ["development"]   // สั่ง tsc ให้เปิด condition นี้ตอน resolve
}
```

มันไม่เปลี่ยนวิธี compile — เปลี่ยนแค่ **ขั้นตอนหาไฟล์** เมื่อ tsc เดิน `exports` map ของ package ชุด condition ที่ใช้เทียบจะมี `development` เพิ่มเข้ามา และเพราะวางไว้บนสุด มันชนะ → tsc อ่าน type จาก `./src/.../index.ts` โดยตรง **ไม่ต้องมี `.d.ts` ใน dist เลย**

ฝั่ง Jest ก็เปิด condition ผ่าน option ของ test environment:

```ts
// jest.config.api-*.ts (node environment)
testEnvironmentOptions: { customExportConditions: ['development', 'node', 'node-addons'] }

// jest.config.web.ts / jest.config.features.ts (jsdom)
testEnvironmentOptions: { customExportConditions: ['development', ''] }
```

> **สำคัญ:** `customExportConditions` เป็นการ *แทนที่* ชุด default ของ environment ไม่ใช่เพิ่มเข้าไป — ฝั่ง jsdom จึงต้องคง `''` (default condition) ไว้ ไม่งั้น package อย่าง `msw/node` จะ resolve ไม่ได้

---

## 4. เดินดูการ resolve ทีละขั้น

โค้ดเดียวกัน: `import { InputModel } from '@demo-shop-system/shop-api-core/command/cancel-bible'`

**โลกที่ 1 — tsc ตอน lint (เปิด `customConditions: ["development"]`):**

```
1. หา package shop-api-core ใน node_modules (pnpm symlink -> libs/.../core)
2. เปิด package.json -> exports -> match "./command/*"  (* = cancel-bible)
3. ไล่ condition: "development" เปิดอยู่ไหม? -> เปิด ✅ ชนะ
4. ได้ ./src/command/cancel-bible/index.ts -> อ่าน type จาก source สดๆ
```

→ ลบ `dist` ทั้ง workspace แล้ว typecheck ยังผ่าน

**โลกที่ 2 — Node รัน app ใน container (ไม่เปิดอะไรพิเศษ):**

```
1-2. เหมือนเดิม
3. ไล่ condition: "development"? ไม่เปิด ❌ ข้าม -> "import"? เปิด ✅ ชนะ
4. ได้ ./dist/command/cancel-bible/index.mjs -> โค้ดที่ build แล้ว
```

ไฟล์ `exports` เดียวกันเป๊ะ ตัวเลือกต่างกันเพราะ "ใครเป็นคนถาม" ไม่มี env var หรือ build flag มาสลับ config

---

## 5. การตั้งค่าครบทุกจุด

ตารางสรุปทุกไฟล์ที่เกี่ยวข้อง (template เหล่านี้ตั้งค่าให้แล้วตั้งแต่ v1.4):

| ไฟล์ | ตั้งอะไร | ทำไม |
|---|---|---|
| `libs/*/package.json` | `"development"` บนสุดของทุก exports entry + `"sideEffects": false` | dev เห็น src, consumer tree-shake ได้ |
| `tsconfig.base.json` | `"customConditions": ["development"]` | ครอบ tsconfig-api-*.base.json ที่ extends ต่อ |
| `tsconfig.features.base.json` | `"customConditions": ["development"]` | frontend libs (moduleResolution: bundler) |
| `apps/*/tsconfig.json`, `tsconfig-build.json` | `"customConditions": ["development"]` | app extends config ภายนอก (เช่น fastify-tsconfig) จึงไม่ inherit base ต้องใส่เอง |
| `jest.config.api-*.ts`, `jest.config.webapi.ts`, `jest.config.functions.ts`, `jest.config.basetypes.ts` | `customExportConditions: ['development','node','node-addons']` | jest node env |
| `jest.config.web.ts`, `jest.config.features.ts` | `customExportConditions: ['development','']` | jsdom — ต้องคง `''` |
| `nx.json` | เอา `^build` ออกจาก lint/test/build (คงที่ serve/release) | lint/test/build ของ lib ไม่ต้องรอ build dependency |
| `apps/*/package.json` | `nx.targets.build.dependsOn: ["^build"]` | app runtime ต้องใช้ dist ของ lib |
| `tsup.lib.config.ts`, `*/tsup.config.ts` | `minify: false` | lib ไม่ต้อง minify; consumer minify เองตอน release |

### ตัวอย่าง package.json เต็ม (lib)

```jsonc
{
  "name": "@my-system/sample-api-service",
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "sideEffects": false,
  "scripts": {
    "lint": "tsc -p tsconfig.json && eslint ./src",
    "build": "tsup --config ../../../tsup.lib.config.ts",
    "test": "jest --runInBand --coverage --no-cache"
  },
  "exports": {
    ".": {
      "development": "./src/index.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    },
    "./command/*": {
      "development": "./src/command/*/index.ts",
      "import": "./dist/command/*/index.mjs",
      "require": "./dist/command/*/index.js",
      "types": "./dist/command/*/index.d.ts"
    },
    "./query/*": {
      "development": "./src/query/*/index.ts",
      "import": "./dist/query/*/index.mjs",
      "require": "./dist/query/*/index.js",
      "types": "./dist/query/*/index.d.ts"
    }
  },
  "dependencies": {
    "@my-system/share-data": "workspace:^"
  },
  "peerDependencies": { "tslib": "^2.3.0" }
}
```

### ตัวอย่าง frontend lib (ไฟล์เป็น .tsx/.ts ใช้ fallback array)

frontend-lib-module มี exports **2 ระดับ**: root `.` (re-export ของ lib) + **1 wildcard entry ต่อ sub-module** (`feature-*` / `ui-*` / `functions`) — เพิ่ม sub-module ใหม่ต้องเพิ่ม entry เสมอ (gen ได้ด้วย `pnpm gen:exports` → `tools/generate-exports-web.sh`):

```jsonc
"exports": {
  ".": {
    "development": ["./lib/main.tsx", "./lib/main.ts"],
    "types": "./dist/types/main.d.ts",
    "import": "./dist/main.js",
    "require": "./dist/main.cjs"
  },
  "./feature-user-management/*": {
    "development": ["./lib/feature-user-management/*.tsx", "./lib/feature-user-management/*.ts"],
    "types": "./dist/types/feature-user-management/*.d.ts",
    "import": "./dist/feature-user-management/*.js",
    "require": "./dist/feature-user-management/*.cjs"
  }
}
```

- resolver จะลองไฟล์ตามลำดับใน array — `.tsx` ก่อน ถ้าไม่เจอค่อย `.ts`
- `*` ใน subpath pattern match ข้าม `/` ได้ → resolve รายไฟล์ทั้ง dev (source) และ prod (dist) เช่น `@scope/<lib>/feature-x/main`
- **กติกา consumer (app/storybook-host):** import feature ผ่าน `@scope/<lib>/feature-<name>/main` เท่านั้น — ห้ามเจาะลึกกว่า `main` (boundary ของ feature) และไม่ตั้ง alias ฝั่ง app ชี้เข้า source ตรง (จะข้าม exports map — เสีย dual-condition ทั้ง dev/build) → ตอน promote เป็น project แก้แค่ prefix `@scope/<lib>/` → `@scope/` (find-replace เดียว ดู [frontend-structure.md](./frontend-structure.md) §10)

> เรื่องการจัดโครง frontend lib (feature / ui-components / ui-functions / ui-state-&lt;vendor&gt;), กฎ peer dependency ของ UI lib, boundary และ promotion ดู [frontend-structure.md](./frontend-structure.md) — ไฟล์นี้เน้นเฉพาะกลไก export/resolution

### ตัวอย่าง nx.json (ส่วน targetDefaults)

```jsonc
"targetDefaults": {
  "lint":  { "inputs": ["default", "{workspaceRoot}/*eslint*"], "cache": true },
  "test":  { "inputs": ["default", "{workspaceRoot}/jest.*"], "cache": true,
             "outputs": ["{workspaceRoot}/coverage/{projectRoot}/"] },
  "build": { "inputs": ["production", "^production", "{workspaceRoot}/*tsconfig*"],
             "outputs": ["{projectRoot}/dist/"], "cache": true },
  "serve":   { "dependsOn": ["^build"] },
  "release": { "dependsOn": ["^build"], "cache": false }
}
```

### ตัวอย่าง override ใน app

```jsonc
// apps/demo-exm-webapi/mcs-fastify/package.json
"nx": { "targets": { "build": { "dependsOn": ["^build"] } } }
```

---

## 6. Nx targets: ใครพึ่ง ^build บ้าง

หลักคิด: *ใส่ `^build` เฉพาะ target ที่ผลิตหรือใช้ artifact ที่จะถูกรันด้วย Node จริง*

| Target | `^build`? | เหตุผล |
|---|---|---|
| `lint` (ทุก project) | ❌ | tsc อ่าน type จาก src ของ dep ผ่าน development condition |
| `test` (ทุก project) | ❌ | jest resolve src ของ dep ตรงๆ |
| `build` ของ **libs** | ❌ | tsup externalize workspace deps + dts อ่านจาก src → build เดี่ยวสมบูรณ์ ขนานกันได้ |
| `build` ของ **apps** | ✅ | runtime artifact ของ app ต้องใช้ dist ของ libs |
| `serve` | ✅ | รันจาก dist |
| `release` | ✅ | ผลิต artifact จริง ต้อง build dependency ครบก่อน |

การเอา `^build` ออก **ไม่ได้ทำให้ dependency graph หาย** — `nx affected` ยังนับครบ (แก้ core → core/service/apps ถูกนับ affected) สิ่งที่หายคือ "ลำดับบังคับของ task" เท่านั้น

กรณี `store-prisma` (lib ที่มี `release` ของตัวเองสำหรับ build เป็น migration image): **ไม่ต้อง override** เพราะ migration image ใช้ schema + migrations + prisma CLI ไม่ใช่ dist ของ lib อื่น และ target `release` มี `^build` ใน targetDefaults คุ้มอยู่แล้ว — ขอแค่สั่งผ่าน `nx release` ไม่ใช่ `pnpm release` ตรงๆ

---

## 7. กฎที่ต้องรักษา

1. `development` ต้องเป็น **key แรก** ของทุก exports entry (condition แรกที่ match ชนะ — เรียงผิดจะกลับไปใช้ dist เงียบๆ โดยไม่มี error)
2. เพิ่ม action ใหม่ (backend) หรือ sub-module ใหม่ (frontend) → ใส่ exports entry ให้ครบทั้ง development/import/require/types — ใช้ `pnpm gen:exports` ได้ทั้งสองฝั่ง แต่**คนละ tool**: backend = `generate-exports.sh` (key จาก `src/*/index.ts`) · frontend = `generate-exports-web.sh` (key จาก `lib/<sub>/main.ts`) — **ห้ามใช้ข้าม convention** (รันตัว backend ใน frontend lib จะได้ exports ว่างทับของเดิม)
3. dependency ระหว่าง lib ต้องประกาศใน `dependencies` แบบ `workspace:^` เสมอ — ไม่งั้น tsup จะ bundle แทน externalize และ pnpm strict isolation จะ resolve ไม่เจอ
4. jest ฝั่ง jsdom ห้ามลบ `''` ออกจาก `customExportConditions`
5. dist จาก `pnpm build` มือทีละ project ห้ามนำไป deploy/publish — ใช้ `nx release` หรือ `build:all` เท่านั้น

---

## 8. Troubleshooting

| อาการ | สาเหตุที่พบบ่อย |
|---|---|
| tsc/jest ยังฟ้อง "Cannot find module" ของ local package | `customConditions`/`customExportConditions` ไม่ได้ตั้ง หรือ `development` ไม่ได้อยู่บนสุดของ exports |
| รัน dev แล้วได้พฤติกรรมของ dist (แก้ src ไม่เห็นผล) | ลำดับ key ผิด — `import`/`types` มาก่อน `development` |
| jest ฝั่ง web/features พัง resolve `msw/node` | ลบ `''` ออกจาก customExportConditions ของ jsdom |
| `Cannot read properties of null (reading 'useState')` / `TypeError` ตอน import ใน renderHook test | dual React — moduleNameMapper pin ต้อง**ครอบ subpath ด้วย** (`^react/(.*)$` + `^react-dom/(.*)$` ไม่ใช่แค่ bare `^react$`) ไม่งั้น `react-dom/client` ที่ testing-library ใช้หลุด pin ไปคนละเวอร์ชัน (template web/features ตั้งให้แล้ว) |
| build app แล้ว runtime หา dist ของ lib ไม่เจอ | app ขาด `nx.targets.build.dependsOn: ["^build"]` |
| tsup error `Expected "}"` หลังแก้ comment ใน config | comment ภาษาไทยมี `/` หรืออักขระที่ทำ JS parse เพี้ยน — ตรวจ syntax |

---

## 9. Migrate workspace เดิม

workspace ที่ generate ด้วย version < 1.4 ใช้ codemod นี้ปรับให้เป็น strategy ใหม่ได้ (idempotent — รันซ้ำได้) ·
เป็น rung แรกของ migration ladder (`migration-v1.4.0.mjs`) — รันผ่าน driver ได้เลย:

```bash
bash workspace-generator/script-generator/migrate/apply-migration.sh <ws> --to 1.4.0
# หรือรันตรง (ไม่ผ่าน driver = ไม่ bump version/log): node migration-v1.4.0.mjs <ws>
```

มันจะ: เอา `^build` ออกจาก nx.json, เพิ่ม `customConditions` ใน tsconfig base + apps, เพิ่ม `customExportConditions` ใน jest ทุกไฟล์, เพิ่ม `development` + `sideEffects` ในทุก lib ที่มี exports, ใส่ override ให้ apps, และปิด minify ใน tsup

หลังรัน: ตรวจ `git diff`, ลบ `dist` ทั้งหมด, แล้วลอง lint/test project ที่มี local dependency เพื่อยืนยันว่าผ่านโดยไม่ต้อง build dependency ก่อน

---

## ดูต่อ

- **public surface ของแต่ละ layer** — core/service เปิด export ราย action (per-subpath) ส่วน client เปิดแค่ `Client` + types (ซ่อน fn ภายใน) ทำไมถึงต่างกัน + ข้อดี/ข้อเสียของ per-subpath vs barrel เดียว อ่านที่ [backend-structure.md §8](./backend-structure.md#export-strategy)

## อ้างอิง

- [Node.js — Conditional exports](https://nodejs.org/api/packages.html#conditional-exports)
- [TypeScript 5.0 — `customConditions`](https://www.typescriptlang.org/tsconfig/#customConditions)
- [Jest — `testEnvironmentOptions` / `customExportConditions`](https://jestjs.io/docs/configuration#testenvironmentoptions-object)
- [Nx — `dependsOn` / affected](https://nx.dev/concepts/task-pipeline-configuration)
