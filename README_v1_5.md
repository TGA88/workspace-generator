# workspace-generator

> Generator สร้าง **pnpm monorepo** (Nx · Fastify · Next.js) แบบ scaffold ครบวงจร:
> backend API (core/service/client/store-prisma/webapi) · frontend (Next.js/Storybook) · infra + black-box test
>
> **เวอร์ชันล่าสุด: v1.5.2** · ต้องใช้ **Node 22+** · 📘 [Developer Handbook](https://bebestdev.com/developer-handbook/) · 📜 [Changelog](./CHANGELOG.md) · ⬆️ [Migration guide](./docs/migration-guide.md) · 🤝 [Contributing](./CONTRIBUTING.md)

## 🧭 หาอะไรอยู่?

| อยากได้ | ไปที่ |
|---|---|
| เข้าใจ **สถาปัตยกรรม / เขียนโค้ดต่อ layer / วิธีเขียน test** (methodology) | 📘 **[Developer Handbook](https://bebestdev.com/developer-handbook/)** (เว็บ · อ่านง่าย) |
| **สร้าง workspace · ใช้ generator (CLI) · รัน test** | README นี้ (↓ Quick Start · 🧪 Test) |
| **อัป (migrate) workspace เป็นเวอร์ชันใหม่** | [docs/migration-guide.md](./docs/migration-guide.md) |
| **พัฒนา generator เอง (contribute)** | [CONTRIBUTING.md](./CONTRIBUTING.md) |

> 📘 handbook = "**เขียนโค้ด / ทำไม**" (methodology + architecture) · repo นี้ = "**ใช้ / รันยังไง**" (เครื่องมือ + คำสั่ง) — คู่กัน ไม่ซ้ำ

## ✨ ทำอะไรได้บ้าง

- **Scaffold workspace** — pnpm + Nx monorepo (`create-workspace` + `init-system`)
- **API scaffolding** — คำสั่งเดียวได้ domain/action ครบชั้น (`pnpm gen:api-*`) + wire route/prisma
- **Backend test (black-box)** — `make api-test` ยิง HTTP เข้า service+DB จริง (contract = SSOT) · in-container `make verify-backend`
- **Frontend** — Next.js web + feature-lib + ui-components + Storybook host
- **Migration** — อัป workspace เดิมขึ้นล่าสุด **คำสั่งเดียว** (driver)

## 🚀 เริ่มต้น (สร้าง workspace ใหม่)

> วาง `workspace-generator/` ไว้ระดับเดียวกับโฟลเดอร์ที่จะสร้าง workspace

```bash
bash workspace-generator/script-generator/create-workspace.sh gu-example-system node-app        # 1) สร้าง monorepo
bash workspace-generator/script-generator/init-system.sh gu-example-system node-app             # 2) init (ตอบ skip-now)
bash workspace-generator/script-generator/update-workspace-config.sh gu-example-system node-app # 3) update config
```
> จากนั้นสร้าง base API package แล้วเติม domain/endpoint ด้วย **scaffolding** (`pnpm gen:api-*`) — ดู [§API Project](#api-project)

## ⬆️ อัป workspace เดิม → ล่าสุด

```bash
bash workspace-generator/script-generator/migrate/apply-migration.sh <ws> --dry-run   # ดูแผนก่อน (ไม่แตะจริง)
bash workspace-generator/script-generator/migrate/apply-migration.sh <ws>             # รันจริง (ไล่ทุก version ที่ค้าง)
```
> driver ไล่ทุก version ที่ค้างให้เอง · `--to` / retry-เมื่อพัง / audit log → **[docs/migration-guide.md](./docs/migration-guide.md)**

## 🧪 รัน test (workspace ที่ gen มา มีเครื่องพร้อม)

workspace-generator สร้าง `Makefile` + `workspaces/infrastructure/` + `workspaces/backend-test/` ให้ = **เครื่องมือรัน api-test ตามที่ handbook สอน** · รันจาก git root ของ workspace:
```bash
make api-test          # black-box: compose ยก DB+API จริง → ยิง HTTP (contract + assertDb) → down -v
make verify-backend    # in-container: lint + tsc + unit test (ไม่ต้องมี DB) · nx variant = make verify-nx-backend
make test              # host node:test เร็ว (ต้อง make api-up ให้ stack ขึ้นก่อน)
```
> **วิธีเขียน contract & test (methodology) → 📘 [handbook › Backend Testing](https://bebestdev.com/developer-handbook/backend-testing.html)** · เพิ่ม endpoint → `pnpm gen:api-*` (ดู [§API Project](#api-project))

## 📚 เอกสาร

| เอกสาร | เนื้อหา |
|---|---|
| [migration-guide](./docs/migration-guide.md) | **อัป workspace เดิม → ล่าสุด** (driver · ladder · audit log) |
| [backend-test-migration](./docs/backend-test-migration.md) | backend-test + infra layer (`make api-test` · contract SSOT) + gotcha |
| [export-strategy](./docs/export-strategy.md) | dual-condition exports + build system (dev tooling ไม่ต้อง build dep ก่อน) |
| [backend-structure](./docs/backend-structure.md) | โครง backend API (core/service/client + DI + ResultV2) |
| [frontend-structure](./docs/frontend-structure.md) · [frontend-dev-workflow](./docs/frontend-dev-workflow.md) | โครง + workflow ฝั่ง frontend |
| [api-scaffolding · user](./docs/api-scaffolding.user-guide.md) · [developer](./docs/api-scaffolding.developer-guide.md) | เพิ่ม API domain/action + แก้ template ของ generator |
| [why-this-architecture](./docs/why-this-architecture.md) | ทำไม template ถึง "ดูเยอะ" — เหตุผลเชิงสถาปัตยกรรม |
| 🤝 [CONTRIBUTING](./CONTRIBUTING.md) | พัฒนา generator: โครง repo · **เพิ่ม migration/version** · release |

> 📘 **doc ฝั่ง architecture/coding มีฉบับเว็บ (อ่านง่าย) ใน [Developer Handbook](https://bebestdev.com/developer-handbook/)** — เช่น
> [why-this-architecture](https://bebestdev.com/developer-handbook/why-this-architecture.html) · [export-strategy](https://bebestdev.com/developer-handbook/export-strategy.html) · [frontend-structure](https://bebestdev.com/developer-handbook/frontend-structure.html) · [frontend-dev-workflow](https://bebestdev.com/developer-handbook/frontend-dev-workflow.html) · [backend-structure](https://bebestdev.com/developer-handbook/backend-structure.html) · [api-scaffolding](https://bebestdev.com/developer-handbook/api-scaffolding.user-guide.html)
> — และมีเนื้อหาเชิงลึกที่ repo นี้ไม่มี (feature-playbook · backend layer-by-layer · testing per-layer · DB architecture standard) ·
> ส่วน **migration / contributing / การรัน (make/CLI)** = อยู่ใน repo นี้ (handbook ไม่มี)

## 📜 ประวัติเวอร์ชัน

ดู **[CHANGELOG.md](./CHANGELOG.md)** — ทุกเวอร์ชัน + link migration ต่อรุ่น · README เก่า: [v1.4](./README_v1_4.md) · [v1.3](./README_v1_3.md)

## สารบัญ (reference)

- [Workspace](#workspace) — create / update config / init system
- [Storybook host](#storybook-host)
- [System Workspace](#system-workspace)
  - [Frontend Project](#frontend-project) — web · frontend-lib-modules · feature · ui-components · ui-state · web-config
  - [API Project](#api-project) — **scaffolding** + base package (core/service/client/store-prisma/webapi)
  - [Global Packages](#global-packages) — ui-common · functions · base-types · fastify-plugins
- [Other (troubleshooting)](#other)

## workspace
คือ location ในการจัดเก็บ source code แบ่งตาม programming language เช่น node-app, python-app, springboot-app และ infrastructure สำหรับ เตรียม environment ในการรัน app
### create workspace
ตัวอย่างการ สร้าง workspace
```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/create-workspace.sh gu-example-system node-app

```
### update workspace config
คือ การupdate command script ใน root package.json และ update base config ต่างๆ เช่น tsconfig,jest,lint เป็นต้น

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/update-workspace-config.sh gu-example-system node-app

```

## Initial package for System workspace
**เมื่อ Initial package แล้วให้ update package ตาม section update workspace configด้วย**
ตัวอย่างการ init system-workspace เพื่อ install and config tools 
```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/init-system.sh gu-example-system node-app

```
ระหว่าง install package จะมีคำถามดังนี้ ให้ตอบ skip-now
![image](assets/Screenshot%202567-12-23%20at%2016.51.52.png)

## Storybook host

### Create
**หลังจาก สร้างมาแล้วก่อน สั่ง run ให้สั่ง build ก่อน 1ครั้ง เพื่อติดตั้ง libs ที่เกี่ยวข้อง**
ตัวอย่างการ generate project type storybook-host
```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-storybook.sh gu-example-system example

```

### Update
ตัวอย่างการ update project storybook-host เพื่อ update reference lib feature
```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/update-sb.sh gu-example-system example

```

### การ Trigger Release Storybook Project ใน pipeline

หากต้องการให้ release storybook project เมือ dependency-project changed ใน pipeline
>dependency-project เช่น  project type เช่น feature-xx,ui-common,ui-components

<br/>
ให้ add command เพิ่มใน package.json โดยให้เปลี่ยน **storybook-host-shared เป็น ชื่อ storybook project ที่ต้องการ**

```json
"trigger:release": "echo 'storybook-host-shared' >> ../../release-app/changed_unsort.txt"
```

---

# System Workspace
## Frontend Project

### Web-Nextjs

- **param1=ชื่อ workspace** เช่น gu-example-system
- **param2=ชื่อ webproject** เช่น demo-exm-web

ตัวอย่างการ generate project type web nextjs
```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-web.sh gu-example-system demo-exm-web

```
### frontend-lib-modules(แนะนำให้ใช้ type นี้ก่อน project type feature)
คือ lib ของ frontend-app โดยชื่อ module จะต้องชื่อเดียวกับ app
โดยประกอบไปด้วย feature กับ ui
- ui คือ share component,customhook,theme ให้กับ feature ต่างๆภายใน module เดียวกัน
- feature คือ program ของ module

**วิธีการใช้งาน**
- สร้าง project frontend-lib-module
- สร้าง sub-module ประเภท feature หรือ ui ด้วย script ใน package.json
- update path alias ของ sub-modules ด้วย script ใน package.json

#### สร้าง project frontend-lib-module

- **param1=ชื่อworkspace**
- **param2=ชื่อappname**

```bash
bash workspace-generator/script-generator/new-frontend-lib-modules.sh gu-example-system demo-exm-web
```

### Feature-Lib
<span style="color:red">เอาไว้ใช้ กรณีที่ frontend-lib-modules มีขนาดใหญ่เกินไป หรือ เจอปัญหา heap out of memory ให้นำ feature หรือ ui แยกมาสร้าง เป็นproject</span>

โดย ให้ Feature-lib และ copy subfolder ทั้งหมด ของ feature ใน frontend-lib-modules มาไว้ที่ folder lib ที่เราพึ่งสร้าง **ชื่อ project feature-lib ที่สร้างใหม่ จะต้องตรงกับ folder feature ใน frontend-lib-modules**

ตัวอย่างการ generate project type feature

- **param1=ชื่อ workspace** เช่น gu-example-system
- **param2=ชื่อ feature** เช่น feature-funny
- **param3=ชื่อ scope  เช่น demo-funny-web แต่ถ้าไม่ใส่ จะ default เป็น shared-web**

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh gu-example-system feature-funny

```

### ui-components
เป็น project ที่ component ,customhooks ที่เอาไว้แชร์ เฉพาะภายใน scope ของ system worksapce เท่านั้น ซึ่งจะไม่ deploy ขึ้น npm
**ใช้ new-feature.sh แต่ไม่ระบุ project name จะได้ project ui-components**

- **param1=ชื่อ workspace** เช่น gu-example-system

<Br/>

**ตัวอย่าง**
```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh gu-example-system 
```

**ผลลัพธ์**
```
|-- libs
    |-- shared-web
        |-- ui-components # this is project. package name is @<system-name>/ui-components
```

### ui-state-redux
ตัวอย่างการ generate project type ui-state

- **param1=ชื่อ workspace** เช่น gu-example-system
- **param2=ชื่อ ui-state** เช่น ui-state-redux หรือ ui-state-zustand ตามprovider ที่ใช้
- **param3=ชื่อ scope  เช่น demo-funny-web แต่ถ้าไม่ใส่ จะ default เป็น shared-web**

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh gu-example-system ui-state-redux

```
หลังจากได้ Projectแล้ว ที่ package.json ให้ลบ package ที่ไม่ได้ใช้ออก และ ติดตั้ง peerDependcies ที่จะใช้ตามต้อง 
**ให้ลบ Code example ออกด้วย**
และ Project นี้ควรเก็บ แต่ actions,reducer,slice เท่านั้น ส่วน createStore ให้ไปสร้างที่ consumer-project(Project ที่นำlibไปใช้งาน) อย่างเช่น web หรือ storybook

<br/>

### web-config

เป็น project ที่ config สำหรับ webproject และ เอาไว้ share ให้ feature project หรือ web,storybook project ใช้งานด้วย

**ใช้ new-feature.sh  แต่ให้ระบุ suffix project name เช่น demo-exm-web-config**

- **param1=ชื่อ workspace**
- **param2=ชื่อ scopename** เช่น demo-exm-web หรือ ถ้าไม่ใส่จะเป็น share-web

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-webconfig.sh gu-example-system  demo-exm-web

```

**ผลลัพธ์**
```
# แบบ ไม่ระบุ scope (recommend)
|-- libs
    |-- shared-web
        |-- config # this is project. package name is @<system-name>/shared-web-config

# แบบ ระบุ scope (recommend)
|-- libs
    |-- demo-exm-web
        |-- config # this is project. package name is @<system-name>/demo-exm-web-config
```

---
## API Project

> 🧩 **โครง/แนวคิด pattern ใหม่ (unified-route: core/service/client + DI + ResultV2 + telemetry):** [docs/backend-structure.md](./docs/backend-structure.md)
> 🚀 **วิธีเพิ่ม API ตั้งแต่ศูนย์ (ใช้งานจริง):** [docs/api-scaffolding.user-guide.md](./docs/api-scaffolding.user-guide.md)
>
> **Workflow ใหม่ (v1.4+) — 2 ขั้น:**
> 1. **สร้าง base package เปล่า** ด้วย `new-api*.sh` ด้านล่าง (สะอาด ไม่มีตัวอย่าง bible) — 1 ชุด `shared-api` (core/service/client) เก็บได้หลาย domain
> 2. **เติม domain/endpoint ด้วย scaffolding** (`pnpm gen:api-*`) จากใน `workspaces/node-app` — ดู [scaffolding](#scaffolding-เพิ่ม-api-domain-unified-route-pattern) ด้านล่าง

### scaffolding: เพิ่ม API domain (unified-route pattern)

> 📖 **คู่มือเต็ม (แก้ field/logic/migration/test + ปัญหาที่เจอบ่อย):** [docs/api-scaffolding.user-guide.md](./docs/api-scaffolding.user-guide.md)

มี 7 คำสั่ง (รันจาก `workspaces/node-app`) — **ไม่ใส่ param ก็ได้ จะถามทีละค่า (TUI)**:

```bash
# 1) slice: core+service+client ของ domain (command create-<domain> + query get-<domain>) + อัปเดต exports/index
pnpm gen:api-domain <scope> <api-pkg> <domain> [layer]
#   เช่น: pnpm gen:api-domain shared-webapi shared-api order
#   [layer] = core|service|client|all (default all) — gen เฉพาะชั้นได้

# 2) wire: data-layer repo (store-prisma) + webapi route + prisma model + deps
pnpm gen:api-wire <scope> <api-pkg> <data-pkg> <webapi-app> <domain>
#   เช่น: pnpm gen:api-wire shared-webapi shared-api demo-shop-data demo-shop-webapi order

# 3) action: เพิ่ม action เดี่ยว (เช่น update/list) เข้า domain เดิม + เพิ่ม DI key อัตโนมัติ
pnpm gen:api-action <scope> <api-pkg> <domain> <command|query> <verb> [layer]
#   เช่น: pnpm gen:api-action shared-webapi shared-api order command update

# 4) promote: grouped domain (ใน shared-api) -> standalone project (<domain>-api แยก, src แบน)
pnpm gen:api-promote <scope> <shared-api> <domain>
#   เช่น: pnpm gen:api-promote shared-webapi shared-api product

# 5) demote: standalone project -> กลับเป็น grouped domain ใน shared-api
pnpm gen:api-demote <scope> <project> <shared-api>
#   เช่น: pnpm gen:api-demote shared-webapi product-api shared-api

# 6) infra: (one-time/system) workspaces/infrastructure + backend-test + root Makefile (api-test ระดับ API)
pnpm gen:infra <service> <db-schema> [scope] [data-pkg] [api-pkg]
#   เช่น: pnpm gen:infra demo-shop-webapi demo-shop

# 7) contract: คู่กัน contract(SSOT) + backend-test node:test ต่อ action (gen:api-wire เรียกให้อัตโนมัติ)
pnpm gen:api-contract <service> <domain> [action]
#   เช่น: pnpm gen:api-contract demo-shop-webapi product update-product   (ว่าง = create+get)
```
> ต้อง clone `workspace-generator` ไว้ระดับเดียวกับ workspace (หรือ set `WORKSPACE_GENERATOR_DIR`) — จำเป็นเฉพาะตอน scaffold; build/test/run ไม่ต้องมี

หรือเรียก bash ตรงๆ (จาก dir แม่ที่มี workspace + generator เป็น sibling):
```bash
bash workspace-generator/script-generator/new-api-domain.sh  <workspace> <scope> <api-pkg> <domain> [generator-dir] [layer]
bash workspace-generator/script-generator/new-api-wire.sh    <workspace> <scope> <api-pkg> <data-pkg> <webapi-app> <domain>
bash workspace-generator/script-generator/new-api-action.sh  <workspace> <scope> <api-pkg> <domain> <command|query> <verb>
bash workspace-generator/script-generator/promote-api-domain.sh <workspace> <scope> <shared-api> <domain>
bash workspace-generator/script-generator/demote-api-domain.sh  <workspace> <scope> <project> <shared-api>
bash workspace-generator/script-generator/new-infrastructure.sh <workspace> <service> <db-schema> [scope] [data-pkg] [api-pkg]
bash workspace-generator/script-generator/new-api-contract.sh   <workspace> <service> <domain> [action]
```
หลัง wire แล้ว: `pnpm prisma:generate` + `pnpm gen:up-script` (migration) ที่ store-prisma แล้วทดสอบด้วย `make test` (ดู user guide)

---

> 📦 **ด้านล่างคือคำสั่งสร้าง _base package_ (ทำครั้งเดียวต่อ API หนึ่งชุด)** — `new-apicore` / `new-apiservice` / `new-apiclient` / `new-storeprisma` / `new-webapi` แล้วค่อยใช้ scaffolding ด้านบนเติม domain/endpoint

### API-CORE
ตัวอย่างการ update project api-core  สำหรับเก็บ abstract layer เช่น interface,type,repository,และ BusinessLogic ที่ต้องการ Share ระหว่าง DataLayer และ ServiceLayer

- **param1=ชื่อ workspace**
- **param2=ชื่อ api**
- **param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-apicore.sh gu-example-system sample-api

```

### API-Service
ตัวอย่างการ update project api-service สำหรับ Provide Action ตาม Business Requirement

- **param1=ชื่อ workspace**
- **param2=ชื่อ api**
- **param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-apiservice.sh gu-example-system sample-api

```

### API-client
ตัวอย่างการ project type api-client สำหรับ provide httpClient สำหรับ request api-service สำหรับ front-end และ backend

- **param1=ชื่อ workspace**
- **param2=ชื่อ api** ช่วย suffix ด้วย -api ด้วย
- **param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-apiclient.sh gu-example-system sample-api

```

### API-StorePrisma
ตัวอย่างการ update project api-store-prisma สำหรับ Provide data layer และ schema model สำหรับ prismaorm

- **param1=ชื่อ workspace**
- **param2=ชื่อ database schema**
- **param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-storeprisma.sh gu-example-system demo

```

### Web-API
ตัวอย่างการ สร้าง Project apps ประเถท webapi

```bash
# param1=ชื่อ workspace
# param2=ชื่อ projectname เช่น demo-exm-webapi

# v1.4+: ระบุชื่อ store-prisma เป็น param4 ได้เลย (ไม่ต้องตามแก้ exm-data ใน package.json เอง)

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-webapi.sh gu-example-system demo-exm-webapi

```
หลังจาก สร้างแล้วให้แก้ไข file package.json 

```json
// (v1.4+ ถ้าระบุ param4 ตอนรัน script แล้ว ข้ามขั้นนี้ได้) ให้แก้ไข exm-data เป็น ชื่อ Folder ของ store-prisma ตัวที่ต้องการ
"release": "cd ../../../ && bash ../build-script/container/release-api.sh demo-exm-webapi mcs-fastify demo-exm-webapi-mcs-fastify exm-data"

```

```json
// ให้แก้ไข -p เป็น port ที่ต้องการ เพื่อ เอาไว้รัน DOCKER ทดสอบใน local
"docker:run": "docker rm -f demo-funny-webapi-mcs-fastify  && cd ../../../release && docker run -p 4001:3000 --env-file container-apps/demo-funny-webapi/mcs-fastify/.env --name demo-funny-webapi-mcs-fastify demo-funny-webapi-mcs-fastify:latest  ",

```

---
## Global Packages
คือ Package ที่สร้างไว้ใน Global Workspace สำหรับ เอาไว้ Share การใช้งาน ในหลายๆ System Workspace

### ui-common
เป็น Project ที่ เก็บ Common-Component เช่น DataTable,Dropdown เป็นต็น , Generic Custom-hook อย่างเช่น useDebounce และ Theme

```bash
# param1=ชื่อ workspace
# param2=ชื่อ project nameที่ต้องการ ควรจะ prefix ด้วย ui-xxx หากไม่ตั้ง จะDefault เป็น ui-common

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-uicommon.sh gu-example-system 

```

### ui-function, api-functions, common-functions
เป็น Project ที่เก็บ แต่ pure function ที่เอาไว้ใช้ ให้ Project อื่นๆ นำไปใช้งาน โดย
- **ui-functions** คือ project ที่มีการใช้ builtin ของ browser เช่น window,localstorage เป็นต้น
- **api-functions** คือ project ที่มีการใช้ builtin ของ nodejs เช่น path,os,fs เป็นต้น
- **common-functions** คือ project ที่รันไ้ด้ทั้ง ใน  browser และ nodejs environment

ตัวอย่าง การสร้าง api-function และ ui-functions
```bash
# param1=ชื่อ workspace
# param2=ให้กำนดว่า เป็น api หรือ ui ตามต้องการ

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-functions.sh gu-example-system ui

```

ตัวอย่าง การสร้าง common-functions
```bash
# param1=ชื่อ workspace

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-functions.sh gu-example-system 

```

### base-types
เป็น Project ที่เก็บ Types สำหรับ นำไปใช้งาน และ จะต้องมี  project implementation ด้วย เช่น
- base-types project คือ ui-router  และ implementation project คือ ui-router-nextjs
- base-types project คือ api-communication  และ implementation project คือ api-communication-aws
    - api-communication จะมี producerItf และ senderItf ให้ใช้งาน

**ตัวอย่าง การสร้าง base-types**
```bash
# param1=ชื่อ workspace
# param2= ชื่อ base-types  ที่ต้องการ

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-basetypes.sh gu-example-system ui-router

```
> หลังสร้าง BaseType Project แล้ว ให้ลบ คำสั่ง test ใน package.json ออกให้หมด

#### ส่วน การสร้าง implementation Project
แนะนำให้ใช้ แบบเดียวกันกับ baseTypes แต่ ให้ Clear โครงสร้าง ใน folder src ก่อน และ สร้าง project ได้ตามต้องการ
**แต่จะต้องเพิ่ม collectCoverage เพื่อเก็บ coverage file ที่จะต้องtest เช่น**
```json
  collectCoverageFrom: [
    '**/*.{ts,tsx}',
    '!**/*.d.ts',
  ],
```

#### ก่อน push commit project BaseType
ให้รันคำสั่ง เพื่อสร้าง export path ใน package.json
```bash
# จะ export ทุก path ที่มี file index.ts
pnpm gen:exports
```
โครงสร้าง folder ใน source ดังนี้
![image](assets/Screenshot%202568-01-06%20at%2019.25.53.png)

จะได้ผลลัพธ์ ใน package.json ดังนี้
```json
  "exports": {
    "./exm": {
      "types": "./dist/exm/index.d.ts",
      "import": "./dist/exm/index.mjs",
      "require": "./dist/exm/index.js"
    },
    "./hello": {
      "types": "./dist/hello/index.d.ts",
      "import": "./dist/hello/index.mjs",
      "require": "./dist/hello/index.js"
    }
  }
```

### fastify-plugins
เป็น project ที่ plugin สำหรับ web framework fastify เพื่อเอาไว้ share ให้ project type webapi ใน system-workspace อื่นๆ

- **param1=ชื่อ workspace** เช่น gu-example-system
- **param2=ชื่อ scope_name** ถ้าต้องการสร้าง project ภายใน scope folder ให้ใส่ค่าเป็น shared-webapi

```bash
# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-plugin-fastify.sh gu-example-system 

```

***

## Other

### วิธีเคลีย package ทั้งหมด เพื่อติดตั้งใหม่

> บน ubuntu ให้ เปิด globstar ก่อน (บน mac เปิด default อยู่แล้ว)

สั่งลบ package ทั้งหมด
```bash
# ที่ folder node-app
rm -rf **/node_modules
rm -rf **/dist

pnpm store prune
```

<br/>

### การแก้ไข nx console error และ มี error ดังนี้
![image](assets/Screenshot%202568-04-10%20at%2011.01.51.png)

แก้ไขโดย
``` bash
#ที่ workspace/node-app
npx nx reset 

# ทำการ clear node package ถ้าเป็น linux ให้ เปิด globstar ก่อน
rm -rf **/node_modules

#และทำการ reload window ของ vs-code หรือ ปิดแล้วเปิดใหม่ก็ได้
```

### ปัญหา react-pdf-viewer installation
ดูวิธีแก้: [stackoverflow #76934122](https://stackoverflow.com/questions/76934122/canvas-node-error-during-installation-of-react-pdf-viewer-package-with-next-js)
