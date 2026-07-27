# Frontend Development Workflow

เอกสารนี้อธิบาย **ขั้นตอนการพัฒนา frontend** ตั้งแต่เริ่มเขียน component จนถึง integrate เข้า web app — ว่าใช้เครื่องมือไหนทำอะไร เมื่อไร และ mock data ยังไง

> 📐 โครงสร้าง lib (feature / ui-components / ui-functions / ui-state) + boundary rules + การ promote folder→project อยู่ใน [frontend-structure.md](./frontend-structure.md) — เอกสารนี้เน้น **"workflow การทำงาน"** ไม่ใช่โครงสร้าง

## สารบัญ

- [1. เครื่องมือแต่ละตัวใช้ตอนไหน (Storybook vs Next.js)](#1-เครื่องมือแต่ละตัวใช้ตอนไหน)
- [2. ทำไมต้องมี storybook-host (ข้อดี + เหตุผล)](#2-ทำไมต้องมี-storybook-host)
- [3. storybook-host: npm scripts + naming convention](#3-storybook-host-scripts--naming)
- [4. ขั้นตอนการพัฒนา (step-by-step)](#4-ขั้นตอนการพัฒนา)
- [5. Mock data: เมื่อไรใช้ MSW เมื่อไร mock fe-client](#5-mock-data)
- [6. Naming conventions (frontend)](#6-naming-conventions)

---

<a id="1-เครื่องมือแต่ละตัวใช้ตอนไหน"></a>

## 1. เครื่องมือแต่ละตัวใช้ตอนไหน

แยกชัดว่า **Storybook** กับ **Next.js (web app)** ทำคนละหน้าที่ — เลือกใช้ตามเป้าหมายของงาน:

| | **Storybook (storybook-host)** | **Next.js (web app)** |
|---|---|---|
| **ใช้พัฒนาอะไร** | UI component / feature container แยกเดี่ยว | หน้าจอจริง + routing + integration ทั้งระบบ |
| **เป้าหมาย** | เห็น component ทุก state/variant เร็ว ๆ ไม่ต้องเปิดทั้งแอป | ประกอบ feature เข้าหน้า, i18n, server/client component, deploy |
| **data** | mock ด้วย MSW (ไม่ต่อ backend จริง) | ต่อ backend จริง หรือ mock ตอน dev |
| **รันด้วย** | `pnpm storybook` (port 6006) | `pnpm serve` (`next dev`) |
| **เมื่อไร** | ระหว่างปั้น component / ทำ UI / review กับ designer-QA | ตอนเอา component มาต่อเป็นหน้า / ทดสอบ flow จริง |

**กฎง่าย ๆ:** ปั้น UI และ logic ของ component ให้เสร็จใน **Storybook** ก่อน → พอ component นิ่งแล้วค่อยเอาไปประกอบเป็นหน้าใน **Next.js**

---

<a id="2-ทำไมต้องมี-storybook-host"></a>

## 2. ทำไมต้องมี storybook-host

`storybook-host` เป็น **project แยก** (ไม่ได้ฝัง Storybook ไว้ในแต่ละ lib) ที่ทำหน้าที่เป็น host รวม stories ของทุก lib ใน workspace — `.storybook/main.ts` กวาด stories ทั้ง workspace:

```ts
stories: [
  '../../../libs/**/feature-*/**/*.stories.@(js|jsx|ts|tsx)',
  '../../../libs/**/ui-*/**/*.stories.@(js|jsx|ts|tsx)',
]
```

**ข้อดี / เหตุผลที่เลือกแบบนี้:**

1. **พัฒนา UI แบบแยกเดี่ยว (isolation)** — ไม่ต้องรัน Next.js เต็มตัวหรือต่อ backend ก็ปั้น component ได้ hot-reload เฉพาะตัวที่แก้ เร็วกว่ามาก
2. **บังคับให้ component decoupled** — ถ้าเขียน story ให้ component ทำงานเดี่ยว ๆ ได้ แปลว่ามันไม่ผูกกับ app context (router/store/data) มากเกินไป = reusable จริง เป็น forcing function ที่ดี
3. **living documentation / visual catalog** — ทีม (รวม designer/QA/PM) เปิด Storybook ที่เดียวเห็น component และ state ทั้งหมดของทุก lib ใน workspace ไม่ต้องไล่อ่านโค้ด
4. **ทดสอบ edge case ผ่าน mock** — ลอง loading / error / empty / ข้อมูลยาว ๆ ได้ครบด้วย MSW + controls โดยไม่ต้องสร้าง data จริงใน backend
5. **แยก tooling หนัก ๆ ออกจาก lib** — Storybook + addon + build tooling เป็น devDependency ของ **host เท่านั้น** → lib (feature/ui) สะอาด ไม่มี dep ของ Storybook ปนเข้า production bundle
6. **host เดียวต่อ system** — 1 system = 1 storybook-host ที่เห็นทุก lib (glob ทั้ง workspace) จึง review/release ที่เดียว; release เป็น static site แชร์ให้ stakeholder ได้ผ่าน `release-storybook`
7. **เข้ากับ promotion** — เพราะ host หา stories จาก glob `feature-*` / `ui-*` ไม่ได้ผูก path ตายตัว ตอน promote feature จาก folder → project (ตาม [frontend-structure.md](./frontend-structure.md)) stories ก็ยังถูกเก็บอัตโนมัติ ไม่ต้องแก้ config host

---

<a id="3-storybook-host-scripts--naming"></a>

## 3. storybook-host: scripts & naming

**ที่ตั้ง:** `workspaces/node-app/storybook-host/<base>/` (เช่น `storybook-host/demo-shop/`)
**package name:** `storybook-host-<base>` (เช่น `storybook-host-demo-shop`) — `<base>` มาจากชื่อ system (`demo-shop-system` → `demo-shop`)

**npm scripts (รันใน `storybook-host/<base>/`):**

| script | ทำอะไร | ใช้เมื่อ |
|---|---|---|
| `pnpm storybook` | `storybook dev -p 6006` — รัน dev server | พัฒนา UI ประจำวัน |
| `pnpm build-storybook` | build เป็น static site | ตรวจ build ก่อน release |
| `pnpm build` | `build:libs` แล้ว `storybook build` — build lib ก่อนค่อย build storybook | CI / release |
| `pnpm build:libs` | `cd ../../ && pnpm build:frontend-libs` | (ถูกเรียกโดย `build`) |
| `pnpm release-storybook` | build + release ผ่าน shell script | deploy static storybook |
| `pnpm update:storybook_alias` | อัปเดต alias path ใน `.storybook/main.ts` | หลังเพิ่ม lib/feature ใหม่ |

> **ครั้งแรกหลังสร้าง host** ต้องสั่ง `pnpm build` 1 ครั้งก่อน เพื่อให้ติดตั้ง libs ที่เกี่ยวข้อง (ดู README หลัก หัวข้อ Storybook host)

**alias ใน `.storybook/main.ts`** ชี้เข้า entry ของแต่ละ lib folder (ตัวอย่าง demo-shop):

```ts
'@feature-product': './libs/demo-shop-lib/lib/feature-product/'
'@ui-components':    './libs/demo-shop-lib/lib/ui-components/'
'@ui-functions':     './libs/demo-shop-lib/lib/ui-functions/'
'@ui-state-redux':   './libs/demo-shop-lib/lib/ui-state-redux/'
```

### Alias & import rules

**ทำไม alias ต้องตั้ง 2 ที่ (tsconfig `paths` + `.storybook/main.ts`)?**
เพราะเป็นคนละ consumer ที่ไม่อ่าน config ของกันและกัน:

- **tsconfig `paths`** → ใช้โดย **TypeScript เท่านั้น** (type-check / IDE intellisense / `tsc` ตอน lint) — path ถูกลบทิ้งตอน compile ไม่มีผลกับ JS ที่ bundle ออกมา
- **Vite `resolve.alias` (ใน `viteFinal`)** → ใช้โดย **ตัว Vite bundler** ที่ build/serve stories จริง โดย default Vite **ไม่อ่าน** tsconfig paths ถ้าไม่ตั้งตรงนี้ → resolve module ไม่เจอตอน build

ทั้งสองต้อง **sync กัน** — ใช้ `pnpm update:storybook_alias` ช่วย sync (ทางเลือก: ใส่ plugin `vite-tsconfig-paths` ให้ Vite อ่าน tsconfig เอง แต่ template นี้เลือกตั้ง alias ตรง ๆ เพื่อความ explicit)

**relative path เมื่อไร / alias เมื่อไร:**

| import | ใช้อะไร | เหตุผล |
|---|---|---|
| **ภายในโมดูลเดียวกัน** (ไฟล์ → พี่น้องในโฟลเดอร์เดียวกัน เช่น `./product-card`) | **relative** (`./ ../`) | ไม่แตะ alias เลย, resolve ตรง ๆ ได้, **รอดตอน promote** (ย้ายทั้งโฟลเดอร์ relative ภายในยังถูก) |
| **ข้ามโมดูล** (feature → ui-components / ui-state) | **alias** (`@ui-components/button`) **เท่านั้น** | (1) relative ข้ามโมดูล **พังตอน promote** (ความลึก `../../` เปลี่ยน) (2) ทะลุ public interface เจาะ internal lib อื่นได้ — alias บังคับเข้าทาง entry `index.ts` |

> สรุป: **relative = เฉพาะภายในโมดูล**, **ข้ามโมดูล = alias เสมอ** — เลยยังต้องมี alias ทั้ง 2 ที่สำหรับ import ข้ามโมดูล

---

<a id="4-ขั้นตอนการพัฒนา"></a>

## 4. ขั้นตอนการพัฒนา (step-by-step)

flow มาตรฐานสำหรับ frontend-dev เมื่อจะทำ feature/หน้าใหม่:

**ขั้นที่ 1 — เตรียม shared ที่ต้องใช้ก่อน (ถ้ายังไม่มี)**
- UI ที่ใช้ซ้ำได้ → สร้างใน `ui-components/<name>/` (`<name>.tsx` + `<name>.css` + `index.ts`)
- pure function (format ราคา ฯลฯ) → `ui-functions/<name>/`
- state ที่ต้อง share → `ui-state-redux/<name>/<name>.slice.ts` (เก็บแค่ slice/reducer/action — **ห้าม** สร้าง store ที่นี่)

**ขั้นที่ 2 — เขียน component พร้อม story (พัฒนาใน Storybook)**
- วาง component ใน feature: `feature-<x>/components/<comp>/<comp>.tsx` · หน้า (entry-point) อยู่ `feature-<x>/pages/<page>/<page>.page.tsx`
- เขียน story คู่กันเสมอ: `__stories__/<comp>.stories.tsx` (title = `feature-product/ProductList` หรือ `ui-components/Button`)
- `pnpm storybook` แล้วปั้น component จนครบทุก state (default / loading / error / empty)
- ถ้า component ต้องเรียก data → ใส่ MSW handler ใน story (ดู §5)

**ขั้นที่ 3 — เขียนเทสต์**
- unit test คู่กับ component: `<comp>/__test__/<comp>.test.tsx` · pure function → `logic/__test__/`
- flow สำคัญ → เขียน play function ใน story + ติด `tags: ['ci']` (เกณฑ์เลือก play vs RTL: handbook `storybook-testing` §5)
- `pnpm lint && pnpm test` ใน lib

**ขั้นที่ 4 — integrate เข้า web app (Next.js)**
- import feature เข้าหน้าใน `apps/<base>-web/nextjs/app/...`
- ตั้ง Redux store จริงที่ระดับ app (`configureStore` + `<Provider>`) — slice มาจาก `ui-state-redux`
- ต่อ data layer จริง (axios + React Query) — endpoint เดียวกับที่ mock ไว้ใน MSW
- `pnpm serve` (`next dev`) ทดสอบ flow จริง

**ขั้นที่ 5 — ก่อนส่งงาน**
- `pnpm lint` (eslint + tsc) ทั้ง lib และ app
- `pnpm build` ที่ storybook-host เพื่อยืนยัน stories build ผ่าน
- `pnpm test-storybook` ที่ storybook-host — smoke ทุก story + play function ผ่าน (handbook `storybook-testing` §6)
- release storybook ให้ designer/QA review ถ้าต้องการ

> **หลักการ:** ทุก component ควรพัฒนาและ "เสร็จ" ใน Storybook ก่อน แล้วค่อยเอาไปต่อใน Next.js — แยก "ทำ UI" ออกจาก "ต่อระบบ" ทำให้แก้บั๊กง่ายและ component reusable

---

<a id="5-mock-data"></a>

## 5. Mock data

เลือกวิธี mock ตาม **ระดับที่ต้องการทดสอบ**:

| สถานการณ์ | ใช้อะไร | เหตุผล |
|---|---|---|
| ทดสอบ component/feature ที่ยิง HTTP จริง (ผ่าน axios/React Query) ใน Storybook หรือ test | **MSW** | intercept ที่ชั้น network — โค้ด data fetching จริงทำงานครบ (loading/error/retry) เหมือน production ต่างแค่ response มาจาก handler |
| อยากลองค่า props / state ตรง ๆ ไม่เกี่ยวกับการเรียก API | **ส่ง props/args ใน story** (Storybook controls) | เบาที่สุด ไม่ต้องตั้ง network |
| component เรียกผ่าน **fe-client/wrapper** (ไม่ได้ยิง HTTP ตรง) และอยาก isolate ออกจาก network | **mock ตัว fe-client** (jest mock / stub) | ถ้าตรรกะอยู่ใน client wrapper การ mock client เร็วและตรงจุดกว่า MSW |

**แนวทางที่โปรเจกต์นี้ใช้ (default = MSW):**

MSW ถูก setup ไว้พร้อมแล้ว:
- **handlers กลาง:** `libs/shared-webapi/shared-api/client/src/mocks/api/handlers.ts` (MSW v2 — `http`, `HttpResponse`) มี handler ของ `product-api` เช่น `GET /product-api/get-product/:id`, `POST /product-api/create-product`
- **Storybook:** `.storybook/preview.tsx` เรียก `initialize()` + `loaders: [mswLoader]`, `.storybook/main.ts` ใส่ addon `msw-storybook-addon`, และมี `public/mockServiceWorker.js` ติดตั้งแล้ว

**ใส่ handler ราย story:**

```tsx
import { handlers } from '@scope/shared-api-client/mocks';   // reuse handler กลาง
// หรือเขียนเฉพาะ story
export const ErrorState = {
  parameters: {
    msw: {
      handlers: [
        http.get('/product-api/get-product/:id', () =>
          HttpResponse.json({ statusCode: 500 }, { status: 500 })),
      ],
    },
  },
};
```

**เมื่อไรเลือก MSW vs mock fe-client:**
- ใช้ **MSW** เป็นหลัก เพราะ test/story ครอบคลุมตั้งแต่ fe-client → axios → React Query ครบ layer (ใกล้ของจริงที่สุด) และ handler reuse ได้ทั้ง Storybook + unit test + ระหว่าง dev web app
- ใช้ **mock fe-client** เฉพาะกรณีอยากตัด network ออกจริง ๆ หรือทดสอบเฉพาะ logic ใน wrapper เอง (เช่น mapping/error handling ภายใน client) ที่ไม่ต้องสน HTTP

> หลีกเลี่ยงการ hard-code data ลง component ตรง ๆ เพื่อ mock — ให้ mock ที่ชั้น network (MSW) หรือ client แทน เพื่อให้ production path ไม่ต้องมีโค้ด mock ปน

---

<a id="6-naming-conventions"></a>

## 6. Naming conventions (frontend)

| สิ่งที่ | Pattern | ตัวอย่าง |
|---|---|---|
| System / workspace | `<corp>-<product>-system` | `demo-shop-system` |
| Frontend lib module | `<base>-lib` | `demo-shop-lib` |
| Web app | `<base>-web` (folder), app ใน `nextjs/` | `demo-shop-web` |
| Storybook host | folder `storybook-host/<base>/`, package `storybook-host-<base>` | `demo-shop` |
| Feature folder | `feature-<name>` | `feature-product` |
| UI shared | `ui-components` / `ui-functions` / `ui-state-<vendor>` | `ui-state-redux` |
| Web config | `<base>-web/config` | `demo-shop-web/config` |
| Component file | `<name>.tsx` (+ `<name>.css`) | `button.tsx` |
| Story file | `<name>.stories.tsx`; title = `<lib-area>/<ComponentName>` | `product-list.stories.tsx` → `feature-product/ProductList` |
| State slice | `<name>.slice.ts` | `cart.slice.ts` |
| Test file | `<name>.test.tsx` ใน `__test__/` | `button.test.tsx` |
| tsconfig alias | `@<folder>/*` ชี้ entry (ห้ามเจาะลึกข้าม entry) | `@feature-product/*` → `./lib/feature-product/*` |

**Boundary rules (ย้ำ):** feature → (ui-components / ui-functions / ui-state) ได้; feature → feature **ห้าม**; shared → feature **ห้าม** — ของที่ feature ใช้ร่วมกันให้ยกขึ้น shared

---

> ดูต่อ: [frontend-structure.md](./frontend-structure.md) (โครงสร้าง + promotion) · [export-strategy.md](./export-strategy.md) (dev-condition build) · [why-this-architecture.md](./why-this-architecture.md) (เหตุผลเชิงสถาปัตยกรรม)
