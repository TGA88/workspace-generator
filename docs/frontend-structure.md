# Frontend Library Structure

เอกสารนี้คือ reference สำหรับ "จัดโครง frontend lib อย่างไร" — เปิดทุกครั้งที่จะสร้าง feature, component, function หรือ state ใหม่

> - **ทำไม**ต้องแบ่งแบบนี้ → [why-this-architecture.md](./why-this-architecture.md#frontend-libs)
> - **build/resolution** ทำงานยังไง (dev-condition, peer dependency mechanics) → [export-strategy.md](./export-strategy.md)

## สารบัญ

- [1. Taxonomy: ประเภทของ frontend lib](#1-taxonomy-ประเภทของ-frontend-lib)
- [2. กฎ 2 ทาง: folder ใน lib vs project แยก](#2-กฎ-2-ทาง-folder-ใน-lib-vs-project-แยก)
- [3. โครงภายใน frontend-lib-module](#3-โครงภายใน-frontend-lib-module)
- [4. Feature boundary — กฎที่สำคัญที่สุด](#4-feature-boundary--กฎที่สำคัญที่สุด)
- [5. Import rules](#5-import-rules)
- [6. State management (ui-state-vendor)](#6-state-management-ui-state-vendor)
- [7. web-config](#7-web-config)
- [8. Dependency rules (peer ไม่ใช่ optional)](#8-dependency-rules-peer-ไม่ใช่-optional)
- [9. Promotion: ยก folder → project](#9-promotion-ยก-folder--project)
- [10. Enforce ด้วยเครื่อง](#10-enforce-ด้วยเครื่อง)

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

---

## 2. กฎ 2 ทาง: folder ใน lib vs project แยก

มีแค่ **2 ที่** ที่ shared frontend code อยู่ได้ — ตัดสินด้วย "ใช้กี่ web":

| ขอบเขตการใช้ | อยู่ที่ไหน | ตัวอย่าง |
|---|---|---|
| ใช้ **web เดียว** | folder ใน frontend-lib-module ของ web นั้น | `shop-web-lib/lib/ui-components/` |
| ใช้ **หลาย web** ใน workspace | project แยก ชื่อ generic (ไม่ prefix) | `@scope/ui-components` |

เหตุผลที่ project generic **ไม่ต้อง prefix ชื่อ web**: มันคือ "ตัวกลางของ workspace มีตัวเดียว" — เหมือน `share-data` ที่ไม่ตั้ง `shop-share-data` ส่วนของที่ผูกกับ web เดียว มันอยู่ใน lib ของ web นั้นซึ่งชื่อ lib ระบุ owner อยู่แล้ว จึงไม่มีทางชนกัน

**หลักเดียวที่ใช้ตัดสินทุกอย่าง:** เริ่มไว้ใกล้ consumer ที่ใช้จริง (folder ใน lib) → ยกขึ้นเป็น project แยกเมื่อมี **consumer ตัวที่ 2** เท่านั้น อย่าแยก project ล่วงหน้า (กัน over-engineering)

---

## 3. โครงภายใน frontend-lib-module

```
libs/shop-web-lib/                         ← frontend-lib-module ของ shop-web (ชื่อ = ของ web ไหน)
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

## 9. Promotion: ยก folder → project

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

## 10. Enforce ด้วยเครื่อง

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
