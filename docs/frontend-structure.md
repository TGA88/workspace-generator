# Frontend Library Structure

เอกสารนี้คือ reference สำหรับ "จัดโครง frontend lib อย่างไร" — เปิดทุกครั้งที่จะสร้าง feature, component, function หรือ state ใหม่

> - **ทำไม**ต้องแบ่งแบบนี้ → [why-this-architecture.md](./why-this-architecture.md#frontend-libs)
> - **build/resolution** ทำงานยังไง (dev-condition, peer dependency mechanics) → [export-strategy.md](./export-strategy.md)
> - **ขั้นตอนพัฒนาจริง** (Storybook vs Next.js, storybook-host scripts, mock/MSW) → [frontend-dev-workflow.md](./frontend-dev-workflow.md)

## สารบัญ

- [1. Taxonomy: ประเภทของ frontend lib](#1-taxonomy-ประเภทของ-frontend-lib)
- [2. กฎ 2 ทาง: folder ใน lib vs project แยก](#2-กฎ-2-ทาง-folder-ใน-lib-vs-project-แยก)
- [3. โครงภายใน frontend-lib-module](#3-โครงภายใน-frontend-lib-module)
- [4. Feature boundary — กฎที่สำคัญที่สุด](#4-feature-boundary--กฎที่สำคัญที่สุด)
- [5. Import rules](#5-import-rules)
- [6. State management (ui-state-vendor)](#6-state-management-ui-state-vendor)
- [7. web-config](#7-web-config)
- [8. Dependency rules (peer ไม่ใช่ optional)](#8-dependency-rules-peer-ไม่ใช่-optional)
- [9. sideEffects กับ CSS — กับดักที่ทำ style หาย](#9-sideeffects-กับ-css--กับดักที่ทำ-style-หาย)
- [10. Promotion: ยก folder → project](#10-promotion-ยก-folder--project)
- [11. Enforce ด้วยเครื่อง](#11-enforce-ด้วยเครื่อง)

---

## 1. Taxonomy: ประเภทของ frontend lib

| บทบาท | ชื่อ | เก็บอะไร | pure? |
|---|---|---|---|
| business vertical slice | `feature-<name>` | UI + logic + state ของ 1 ฟีเจอร์ | ไม่ |
| shared component/hook/theme | `ui-components` | component, custom hook, theme ที่ใช้ซ้ำข้าม feature | ส่วนใหญ่ |
| shared pure function | `ui-functions` | pure function ฝั่ง browser (format, validate, calc) | ✅ |
| shared state | `ui-state-<vendor>` | slice/reducer/action เช่น `ui-state-redux`, `ui-state-zustand` | reducer = ✅ |

> ชื่อเหล่านี้ใช้ **เหมือนกันทั้งตอนเป็น folder ใน lib และตอนเป็น project แยก** — เพื่อให้ promote เป็นแค่ "ย้าย" ไม่ใช่ "rename" (ดู §9)

หมายเหตุชื่อที่ต้องระวัง:
- shared component = **`ui-components`** (ไม่ใช่ `ui`)
- shared state = **`ui-state-<vendor>`** เสมอ — ไม่มี `ui-state` เฉยๆ, vendor ต่อท้ายเสมอ (`ui-state-redux`)

### การตั้งชื่อ project/folder ระดับ workspace

สมมติ repo (= workspace/system) ชื่อ `demo-shop-system` รูปแบบ `<corp|product>-<system>-system` → base = `demo-shop` (corp `demo` + system `shop`) — ตั้งชื่อทุก project เป็น `demo-shop-<suffix>`:

| สิ่งที่ | ชื่อ | location |
|---|---|---|
| frontend-lib-module | `demo-shop-lib` | `libs/demo-shop-lib/` |
| web-config (scope = web app) | `demo-shop-web/config` | `libs/demo-shop-web/config/` |
| web app | `demo-shop-web` | `apps/demo-shop-web/nextjs/` |
| storybook host | `demo-shop` | `storybook-host/demo-shop/` |
| feature/shared ที่ promote (web เดียว) | — | `libs/demo-shop-web/<name>/` |
| feature/shared ที่ promote (หลาย web) | generic | `libs/shared-web/<name>/` |

จุดสำคัญ: **frontend-lib-module (`demo-shop-lib`) กับ web scope folder (`demo-shop-web`) เป็นคนละ folder ที่ libs root** ไม่ใช่ lib ซ้อนใน scope — เพื่อให้เวลา promote feature เป็น project มันไปอยู่ใต้ `libs/demo-shop-web/` (scope ของ web ตัวนั้น) แยกออกจากตัว lib ได้สะอาด

---

## 2. กฎ 2 ทาง: folder ใน lib vs project แยก

มีแค่ **2 ที่** ที่ shared frontend code อยู่ได้ — ตัดสินด้วย "ใช้กี่ web":

| ขอบเขตการใช้ | อยู่ที่ไหน | ตัวอย่าง |
|---|---|---|
| ใช้ **web เดียว** | folder ใน frontend-lib-module ของ web นั้น | `demo-shop-lib/lib/ui-components/` |
| ใช้ **หลาย web** ใน workspace | project แยก ชื่อ generic (ไม่ prefix) | `@scope/ui-components` |

เหตุผลที่ project generic **ไม่ต้อง prefix ชื่อ web**: มันคือ "ตัวกลางของ workspace มีตัวเดียว" — เหมือน `share-data` ที่ไม่ตั้ง `shop-share-data` ส่วนของที่ผูกกับ web เดียว มันอยู่ใน lib ของ web นั้นซึ่งชื่อ lib ระบุ owner อยู่แล้ว จึงไม่มีทางชนกัน

**หลักเดียวที่ใช้ตัดสินทุกอย่าง:** เริ่มไว้ใกล้ consumer ที่ใช้จริง (folder ใน lib) → ยกขึ้นเป็น project แยกเมื่อมี **consumer ตัวที่ 2** เท่านั้น อย่าแยก project ล่วงหน้า (กัน over-engineering)

---

## 3. โครงภายใน frontend-lib-module

```
libs/demo-shop-lib/                         ← frontend-lib-module (base demo-shop)
  lib/
    feature-cart/                          ← business slice
      components/
      containers/
      hooks/
      functions/
      types/
      mocks/
      main.ts                              ← entry (export สิ่งที่ให้ภายนอกใช้)
    feature-checkout/
      ...
    ui-components/                          ← shared UI ภายใน web นี้ (ยังไม่ข้าม web)
    ui-functions/                           ← shared pure function ภายใน web นี้
    ui-state-redux/                         ← shared state ภายใน web นี้ (slice/reducer/action)
    main.ts                                ← re-export ระดับ lib
```

แต่ละ `feature-*` เป็น mini-package: เปิดสิ่งที่ให้คนอื่นใช้ผ่าน `main.ts` เท่านั้น ไม่ให้คนนอกเจาะเข้าไฟล์ภายในตรงๆ

---

## 4. Feature boundary — กฎที่สำคัญที่สุด

**feature ห้าม import feature อื่นเด็ดขาด** — แต่ละ feature เป็น boundary ที่แยกขาดจากกัน

ทิศทาง dependency ที่ถูก:

```
feature-cart     ─┐
feature-checkout ─┼─→  ui-components / ui-functions / ui-state-redux   (shared)
feature-search   ─┘
                          (shared ห้าม import กลับขึ้น feature)
```

| จาก → ไป | อนุญาต? |
|---|---|
| feature → shared (ui-components / ui-functions / ui-state-*) | ✅ |
| feature → feature | ❌ ห้าม |
| shared → feature | ❌ ห้าม (จะ circular ทันที และ promote ไม่ได้) |
| shared → shared (มีทิศ เช่น ui-components → ui-functions) | ✅ |

**ถ้า feature 2 ตัวต้องใช้ของเดียวกัน = ของนั้นไม่ใช่ของ feature ใดเลย** → ยกขึ้น shared ตามประเภท:
- component/hook → `ui-components`
- pure function → `ui-functions`
- state → `ui-state-<vendor>`

กฎ "ห้าม feature อ้างกัน" จึงเป็น forcing function ที่บังคับให้ shared code ไปอยู่ที่ถูกที่อัตโนมัติ — ไม่ใช่ข้อจำกัด แต่เป็นกลไกกัน distributed monolith ระดับ folder

ระวัง 2 ด้าน:
- **over-sharing**: อย่ายกขึ้น shared จนกว่าจะมี consumer feature ตัวที่ 2 จริง — ก่อนหน้านั้นเก็บใน feature ตัวเอง (`feature-cart/components/`)
- **business leak ตอน promote**: ของที่ยกขึ้น `ui-components` ต้อง generic (รับ props/callback) ห้ามมี business ของ feature เดิมฝังอยู่ ไม่งั้น feature อื่นใช้แล้วเพี้ยน

---

## 5. Import rules

| จาก → ไป | ใช้ | เหตุผล |
|---|---|---|
| ภายใน sub-module เดียวกัน (ตื้น 1-2 ชั้น) | relative `./` `../` | promote แล้วไม่ต้องแตะ, สื่อว่าผูกกันแน่น |
| ภายใน sub-module เดียวกัน (ลึก >2 ชั้น) | alias ของตัวเอง (ออปชัน) | เลี่ยง `../../../` ที่อ่านยาก |
| ข้าม sub-module | alias ชี้ **entry** เช่น `@feature-cart` → `feature-cart/main.ts` | cross-boundary signal + promote ง่าย |
| เจาะลึกเข้าไฟล์ข้างใน sub-module อื่น | ❌ ห้าม | ทำลาย encapsulation แม้ใช้ alias |
| ใช้ของนอก lib (package อื่น) | package name `@scope/...` | — |

แนะนำ: ภายใน sub-module ใช้ relative เป็นหลัก (promote แล้วไม่ต้องแก้) — ใช้ alias ของตัวเองเฉพาะตอน relative ลึกเกิน 2-3 ชั้นจริงๆ

ตัวอย่าง tsconfig paths (ต่อ sub-module, ชี้ entry):

```jsonc
"paths": {
  "@feature-cart/*": ["./lib/feature-cart/*"],
  "@ui-components/*": ["./lib/ui-components/*"],
  "@ui-functions/*": ["./lib/ui-functions/*"],
  "@ui-state-redux/*": ["./lib/ui-state-redux/*"]
}
```

---

## 6. State management (ui-state-vendor)

**แยกตาม vendor + suffix เสมอ — ห้ามรวมหลาย vendor ในตัวเดียว**

- `ui-state-redux`, `ui-state-zustand` — แต่ละตัว dependency เป็น peer เฉพาะ vendor ของมัน
- **ห้าม** ทำ `ui-state-management` ที่ยัดทุก vendar แล้วใส่ optional dependency เพราะ:
  - `optionalDependencies` ไม่ได้แปลว่า "เลือกติดตั้ง" — pnpm/npm ยังพยายามติดตั้งทั้งคู่อยู่ดี
  - package เดียวที่ export ทั้ง redux และ zustand จะแชร์ build/version/release/affected กัน — เปลี่ยนฝั่งเดียวกระทบทั้งคู่
  - redux กับ zustand มี API คนละแบบ การรวมไม่ได้ทำให้ swap ได้จริง (consumer code ผูกกับ API vendor อยู่ดี)

กฎทอง: **`createStore` / `configureStore` ห้ามอยู่ใน lib** — lib เก็บแค่ slice/reducer/action/selector (pure) ส่วน store instance ไปสร้างที่ consumer (web/storybook) แต่ละ web `configureStore` เลือกเฉพาะ slice ที่ตัวเองใช้ → แต่ละ web มี store ของตัวเอง ไม่กระทบกัน

> ข้อยกเว้นเดียวที่รวมได้ = ทำเป็น contract + adapter จริง (interface กลาง `ui-state` + implementation `ui-state-redux`) แบบ base-types + implementation — แต่นั่นคืองานคนละขนาด ทำเมื่อตั้งใจจะ swap vendor จริงเท่านั้น

---

## 7. web-config

เก็บ config ของ web (env, API URL, timeout, feature flag)

| ใช้กี่ web | อยู่ที่ไหน |
|---|---|
| web เดียว (default) | `shop-web/config` (specific ตามชื่อ web) |
| หลาย web | `shared-web/config` |

แนะนำ **default ไปที่ specific** (`shop-web/config`) เพราะ config ส่วนใหญ่ผูกกับแอปจริง (เช่น SYSTEM_CODE, CLIENT_ID) — มี web ตัวที่ 2 ใช้ config เดียวกันค่อยยกขึ้น `shared-web/config`

ต้องเป็น **leaf package** เสมอ: feature/web/storybook depend ลงมาที่ config ได้ แต่ config ห้าม depend กลับขึ้นไป

---

## 8. Dependency rules (peer ไม่ใช่ optional)

frontend lib ที่ให้คนอื่นใช้ → dependency ของ framework/library ที่ต้องใช้ร่วมกับ consumer ต้องเป็น **`peerDependencies`** เสมอ:

```jsonc
"peerDependencies": {
  "react": "^18.3.1",
  "react-dom": "^18.3.1",
  "@reduxjs/toolkit": "^2.0.0",   // สำหรับ ui-state-redux
  "react-redux": "^9.0.0"
}
```

ทำไม peer ไม่ใช่ optional / dependency:
- **react / react-redux ต้องเป็นสำเนาเดียวกับ consumer** — ถ้าได้คนละสำเนา hooks จะพัง (`useState`/`useSelector` อ่าน context ไม่เจอ) เหมือน dual-React
- `dependencies` (ปกติ) จะ bundle สำเนาของ lib เข้าไป → ได้ React/redux ซ้อน
- `optionalDependencies` แปลว่า "ไม่มีก็รันต่อได้" ซึ่งไม่จริง — lib พวกนี้ขาด react/redux ไม่ได้

> รายละเอียด resolution กับ dev-condition ดู [export-strategy.md](./export-strategy.md)

---

## 9. sideEffects กับ CSS — กับดักที่ทำ style หาย

field `sideEffects` ใน package.json บอก bundler ว่า "ไฟล์ในแพ็กเกจนี้มี side effect ไหม" — side effect = import แล้วเกิดผลข้างเคียงนอกเหนือจากการ export ค่า

**กฎตามประเภท lib:**

| lib | sideEffects | เหตุผล |
|---|---|---|
| backend (api-*, store-prisma, functions, base-types) | `false` | ไม่มี CSS — tree-shake ได้เต็มที่ |
| **frontend (features, ui-components)** | `["**/*.css", "**/*.scss"]` | มี CSS import ที่ห้ามโดน tree-shake |

### ทำไม `false` ทำ CSS หาย

CSS import เป็น **side-effect ล้วนๆ** — ไม่ export อะไร จุดประสงค์เดียวคือ "ฉีด style":

```ts
import './button.css'   // ไม่มี binding ออกมา — มีไว้เพื่อ side effect (ฉีด style) เท่านั้น
```

ตั้ง `sideEffects: false` = บอก bundler ว่า "ทุกไฟล์ปลอดภัย ถ้า export ไม่ถูกใช้ก็ลบได้" → bundler เห็น `import './button.css'` ไม่มีใคร import ตัวแปรจากมัน → **มองว่าไร้ประโยชน์แล้ว tree-shake ทิ้ง** → component แสดงผลแต่ **ไม่มี style** ใน production

อาการนี้ร้ายเพราะ **dev mode มักไม่ tree-shake** → ทุกอย่างดูปกติตอน dev ไปโผล่พังตอน production build เท่านั้น

```jsonc
// ❌ ผิด สำหรับ frontend lib ที่มี CSS — style จะหายตอน build
"sideEffects": false

// ✅ ถูก — "ทุกไฟล์ปลอด side-effect ยกเว้น .css/.scss" → เก็บ CSS import ไว้ แต่ JS ยัง tree-shake ได้
"sideEffects": ["**/*.css", "**/*.scss"]
```

### กรณี CSS / SCSS module

```ts
import styles from './button.module.css'   // อันนี้ export class map
<div className={styles.primary} />          // และถูกใช้จริง
```

CSS module ปลอดภัยกว่า plain import เพราะมัน export ค่าและถูกใช้ bundler จึงไม่ค่อย drop — **แต่ไม่ปลอดภัย 100%** เพราะ compiled output ยังมี side effect คือการฉีด CSS อยู่ ในบาง edge case (เช่น style แยกไปคนละ chunk) bundler อาจเก็บ class map แต่ตัดส่วนฉีด style วิธีที่ปลอดภัยคือ **ใส่ทั้ง `**/*.css` และ `**/*.scss` ใน allowlist เสมอ** ไม่ต้องเสี่ยง (scss ครอบกรณีที่ source ยัง `import './x.scss'` ก่อน compile ด้วย)

> สรุป: frontend lib ที่แตะ CSS/SCSS ห้ามใช้ `sideEffects: false` เด็ดขาด ใช้ allowlist `["**/*.css", "**/*.scss"]` — เป็นกฎที่ template v1.4 ตั้งให้แล้ว แต่ถ้าสร้าง lib เองต้องระวังจุดนี้

---

## 10. Promotion: ยก folder → project

### เมื่อไหร่ต้อง promote (2 เหตุผล)

1. **มี consumer ตัวที่ 2 (web/module อื่น)** → ยกขึ้น **project generic** ที่ `libs/shared-web/<name>` เพื่อแชร์ข้าม web
2. **frontend-lib-module ใหญ่เกินจน build เจอ heap out of memory** → split เฉพาะ sub-module ที่โต (feature/ui) ออกเป็น **project แยก** แต่ยังเป็นของ web เดียว จึงไปอยู่ใต้ scope ของ web นั้น `libs/demo-shop-web/<name>`

เหตุผลที่กรณี 2 ไป `libs/demo-shop-web/` (ไม่ใช่ `shared-web`): มันยังเป็นของ web เดียว — การ split เป็นการแก้ปัญหา build memory/เวลา ไม่ใช่การแชร์ข้าม web ดังนั้นวางใต้ scope ของ web ตัวเจ้าของ เพื่อให้ ownership ชัด และถ้าวันหลังมี web ที่ 2 มาใช้ค่อยยกขึ้น `shared-web` อีกที (README เรียก project ประเภทนี้ว่า Feature-Lib — ใช้ตอน frontend-lib-module ใหญ่เกินหรือ heap OOM)

> เมื่อ frontend-lib-module โตขึ้นเรื่อยๆ `vite build` / `tsc` จะกิน memory มากขึ้นจน Node heap เต็ม (JavaScript heap out of memory) การ split sub-module ที่ใหญ่ออกเป็น project แยกช่วยให้ build ทีละหน่วยเล็กลง + Nx affected build เฉพาะส่วนที่เปลี่ยน

### ขั้นตอน (pure move + mechanical rewiring)

เมื่อ shared folder ใน lib มี consumer ตัวที่ 2 (web อื่น) → ยกเป็น project แยก เป็น **pure move + mechanical rewiring** (ไม่ต้องตีความ ถ้าเขียนตามกฎมาตั้งแต่แรก):

1. สร้าง project type ชื่อเดียวกับ folder (เช่น `ui-state-redux` → project `@scope/ui-state-redux`)
2. `move` folder `ui-state-redux/` ออกมา rename เป็น `lib/` (หรือ `src/`) ใต้ project ใหม่
3. **import ภายใน** ที่เป็น relative → ไม่ต้องแตะ (ย้ายทั้งก้อน relative ยังถูก)
4. **import จาก consumer** เปลี่ยน alias เดิม (`@ui-state-redux/*`) → package name (`@scope/ui-state-redux`) — find-replace
5. ย้าย **peerDependencies** ที่เกี่ยว (redux/react-redux) มาที่ package.json ของ project ใหม่
6. ตั้ง **exports** ของ project ใหม่ให้ชี้ระดับ action + dev-condition (`development`) ตาม [export-strategy.md](./export-strategy.md)

เงื่อนไขเดียวที่ทำให้ขั้นตอนข้างบนเป็น pure move: **slice/component ต้อง assumption-free ตั้งแต่ตอนเขียน** (ไม่ฝัง config/business ของ web เฉพาะ) — เป็น invariant ที่ enforce ตอนเขียน ไม่ใช่ตอน move ถ้ารักษาไว้ promote ก็แค่ย้ายไฟล์

consumer ทั้งเก่าและใหม่เลือก slice ที่ตัวเองใช้ผ่าน `configureStore` ของแต่ละ web เหมือนเดิม — การเพิ่ม consumer ไม่ต้องแก้อะไรใน lib

---

## 11. Enforce ด้วยเครื่อง

กฎ boundary จะพังถ้าพึ่งวินัยคนตอน deadline บีบ — ต้อง enforce อัตโนมัติด้วย `@nx/enforce-module-boundaries` + tags:

```jsonc
// tag แต่ละ sub-module / project
"feature-*"                              → "type:feature"
"ui-components", "ui-functions",
"ui-state-*"                             → "type:shared-ui"
"*-config"                               → "type:config"

// rules
"type:feature"   → depend ได้เฉพาะ ["type:shared-ui", "type:config"]
"type:shared-ui" → depend ได้เฉพาะ ["type:shared-ui", "type:config"]
"type:config"    → depend ไม่ได้ขึ้นใคร (leaf)
// feature → feature ไม่อยู่ใน allow list = error อัตโนมัติ
```

เสริมด้วย ESLint:
- `import/no-relative-packages` — กันข้าม sub-module ด้วย relative
- กฎห้าม relative ลึกเกิน N ชั้น

แบบนี้ใครเขียน `import ... from '@feature-other'` ใน feature → lint แดงทันที ไม่ต้องรอ reviewer

---

## 12. Setup commands หลังเพิ่ม sub-module

ทุกครั้งที่เพิ่ม/ลบ sub-module ใน frontend-lib-module ต้องรัน 2 คำสั่งนี้ในโฟลเดอร์ lib (ไม่งั้น alias ไม่ครบ / build พัง):

```bash
pnpm update:alias-paths   # gen alias @<sub>/* ลง tsconfig.json, tsconfig.build.json, jest.config.ts, vite.config.ts
pnpm update:config        # แก้ extends/relative path ให้ถูกตามความลึกของ project (เช่น tsconfig.build.json extends ../../ ไม่ใช่ ../../../)
```

> verified (template v1.4) ด้วยการ generate frontend stack จริงแล้ว lint / jest / vite build / storybook build ผ่านครบ:
> - `update:alias-paths` อัปเดต **ทั้ง** tsconfig.json (editor/lint/jest) และ tsconfig.build.json (build) — ถ้าขาด build.json จะ resolve `@ui-components` ไม่เจอตอน `tsc -p tsconfig.build.json`
> - `update:config` จำเป็นเพราะ template tsconfig.build.json extends `../../../` (สำหรับ feature-lib 3 ชั้น) แต่ frontend-lib-module อยู่ 2 ชั้น ต้องแก้เป็น `../../`
> - react-pin อยู่ที่ base jest config (`jest.config.features.ts`/`jest.config.web.ts`) ไม่ใช่ per-lib — เพราะ `update:alias-paths` เขียน moduleNameMapper ของ per-lib ใหม่ทับ

หมายเหตุ tsconfig 2 ไฟล์: **`tsconfig.json` = ให้ VSCode/editor + lint + jest** (จะได้ไม่มี error ใน editor), **`tsconfig.build.json` = ใช้ตอน build** — แยกกันโดยตั้งใจ ดังนั้น alias ต้องอยู่ครบทั้งสองไฟล์
