# workspace-generator
script to create pnpm workspace boilerplate

## workspace
ตัวอย่างการ สร้าง workspace
```bash
# pwd is folder workspace-template
# bash script-generator/template/create-workspace.sh [parameter1:workspace-folder] [programing-type]
bash script-generator/create-workspace.sh gu-example-system node-app

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/create-workspace.sh gu-example-system node-app

```

## Initial package for System workspace
ตัวอย่างการ init system-workspace เพื่อ intall and config tools 
```bash
# pwd is folder workspace-template
bash script-generator/init-system.sh gu-example-system node-app

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/init-system.sh gu-example-system node-app

```
ระหว่าง install package จะมีคถามดังนี้ ให้ตอบ skip-now
![image](assets/Screenshot%202567-12-23%20at%2016.51.52.png)

## Storybook host

### Create
ตัวอย่างการ generate project type storybook-host
```bash
# pwd is folder workspace-template
bash script-generator/new-storybook.sh gu-example-system example

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-storybook.sh gu-example-system example

```

### Update
ตัวอย่างการ update project storybook-host เพื่อ update reference lib feature
```bash
# pwd is folder workspace-template
bash script-generator/update-sb.sh gu-example-system example

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/update-sb.sh gu-example-system example

```
---

# System Workspace
## Frontend Project

### Web-Nextjs
**param1=ชื่อ workspace** เช่น gu-example-system
**param2=ชื่อ webproject** เช่น demo-exm-web
ตัวอย่างการ generate project type web nextjs
```bash
# pwd is folder workspace-template
bash script-generator/new-web.sh gu-example-system demo-exm-web

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-web.sh gu-example-system demo-exm-web

```
### Feature-Lib
ตัวอย่างการ generate project type feature
**param1=ชื่อ workspace** เช่น gu-example-system
**param2=ชื่อ fetaure** เช่น feature-funny
**param3=ชื่อ scope  เช่น demo-funny-web แต่ถ้าไม่ใส่ จะ default เป็น shared-web**
```bash
# pwd is folder workspace-template
bash script-generator/new-feature.sh gu-example-system feature-funny

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh gu-example-system feature-funny

```

### ui-components
เป็น project ที่ component ,customhooks ที่เอาไว้แชร์ เฉพาะภายใน scope ของ system worksapce เท่านั้น ซึ่งจะไม่ deploy ขึ้น npm
**ใช้ new-feature.sh แต่ไม่ระบุ project name จะได้ project ui-components**

**param1=ชื่อ workspace** เช่น gu-example-system
**param2=ชื่อ fetaure** ถ้าต้องการเปลี่ยน scope ให้ระบุ param2=ui-components
**param3=ชื่อ scope  เช่น demo-funny-web แต่ถ้าไม่ใส่ จะ default เป็น shared-weba**
```bash
# pwd is folder workspace-template
bash script-generator/new-feature.sh gu-example-system 

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh gu-example-system 

```

### ui-state-redux
ตัวอย่างการ generate project type ui-state
**param1=ชื่อ workspace** เช่น gu-example-system
**param2=ชื่อ ui-state** เช่น ui-state-redux หรือ ui-state-zudstand ตามprovider ที่ใช้
**param3=ชื่อ scope  เช่น demo-funny-web แต่ถ้าไม่ใส่ จะ default เป็น shared-web**
```bash
# pwd is folder workspace-template
bash script-generator/new-feature.sh gu-example-system ui-state-redux

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh gu-example-system ui-state-redux

```
หลังจากได้ Projectแล้ว ที่ package.json ให้ลบ package ที่ไม่ได้ใช้ออก และ ติดตั้ง peerDependcies ที่จะใช้ตามต้อง 
**ให้ลบ Code example ออกด้วย**
และ Project นี้ควรเก็บ แต่ actions,reducer,slice เท่านั้น ส่วน createStore ให้ไปสร้างที่ consumer-project(Project ที่นำlibไปใช้งาน) อย่างเช่น web หรือ storybook

<br/>


### web-config

เป็น project ที่ config สำหรับ webproject และ เอาไว้ share ให้ feature project ใช้งานด้วย

**ใช้ new-feature.sh  แต่ให้ระบุ suffix project name เช่น demo-exm-web-config**

**param1=ชื่อ workspace**
**param2=ชื่อ scopename** เช่น demo-exm-web หรือ ถ้าไม่ใส่จะเป็น share-web
```bash
# pwd is folder workspace-template
bash script-generator/new-webconfig.sh gu-example-system  demo-exm-web

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-webconfig.sh gu-example-system  demo-exm-web

```

---
## API Project
### API-CORE
ตัวอย่างการ update project api-core  สำหรับเก็บ abstract layer เช่น interface,type,repository,และ BusinessLogic ที่ต้องการ Share ระหว่าง DataLayer และ ServiceLayer

**param1=ชื่อ workspace**
**param2=ชื่อ api**
**param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**
```bash
# pwd is folder workspace-template
bash script-generator/new-apicore.sh gu-example-system sample-api

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-apicore.sh gu-example-system sample-api

```
### API-Service
ตัวอย่างการ update project api-service สำหรับ Provide Action ตาม Business Requirement

**param1=ชื่อ workspace**
**param2=ชื่อ api**
**param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**

```bash

# pwd is folder workspace-template
bash script-generator/new-apiservice.sh gu-example-system sample-api

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-service.sh gu-example-system sample-api

```

### API-StorePrisma
ตัวอย่างการ update project api-store-prisma สำหรับ Provide data layer และ schema model สำหรับ prismaorm

**param1=ชื่อ workspace**
**param2=ชื่อ database schema**
**param3=ชื่อ scope  เช่น demo-funny-webapi แต่ถ้าไม่ใส่ จะ default เป็น shared-webapi**
```bash

# pwd is folder workspace-template
bash script-generator/new-storeprisma.sh gu-example-system demo

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-storeprisma.sh gu-example-system demo

```

### Web-API
ตัวอย่างการ สร้าง Project apps ประเถท webapi

```bash
# param1=ชื่อ workspace
# param2=ชื่อ projectname เช่น demo-exm-webapi

# pwd is folder workspace-template
bash script-generator/new-webapi.sh gu-example-system demo-exm-webapi

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-webapi.sh gu-example-system demo-exm-webapi

```
หลังจาก สร้างแล้วให้แก้ไข file package.json 

```json
// ให้แก้ไข exm-data เป็น ชื่อ Folder ของ store-prisma ตัวที่้จต้องการ
"release": "cd ../../../ && bash ../build-script/container/release-api.sh demo-exm-webapi mcs-fastify demo-exm-webapi-mcs-fastify exm-data"

```

```json
// ให้แก้ไข -p เป็น port ที่ต้องการ เพื่อ เอาไว้รัน DOCKER ทดสอบใน local
"docker:run": "docker rm -f demo-funny-webapi-mcs-fastify  && cd ../../../release && docker run -p 4001:3000 --env-file container-apps/demo-funny-webapi/mcs-fastify/.env --name demo-funny-webapi-mcs-fastify demo-funny-webapi-mcs-fastify:latest  ",

```

---
## Global Packagaes
คือ Package ที่สร้างไว้ใน Global Workspace สำหรับ เอาไว้ Share การใช้งาน ในหลายๆ System Workspace

### ui-common
เป็น Project ที่ เก็บ Common-Component เช่น DataTable,Dropdown เป็นต็น , Generic Custom-hook อย่างเช่น useDebounce และ Theme

```bash
# param1=ชื่อ workspace
# param2=ชื่อ project nameที่ต้องการ ควรจะ prefix ด้วย ui-xxx หากไม่ตั้ง จะDefault เป็น ui-common

# pwd is folder workspace-template
bash script-generator/new-uicommon.sh gu-example-system 

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-uicommon.sh gu-example-system 

```

### ui-function, api-functions, common-funtions
เป็น Project ที่เก็บ แต่ pure function ที่เอาไว้ใช้ ให้ Project อื่นๆ นำไปใช้งาน โดย
- **ui-functions** คือ project ที่มีการใช้ builtin ของ browser เช่น window,localstorage เป็นต้น
- **api-functions** คือ project ที่มีการใช้ buitin ของ nodejs เช่น path,os,fs เป็นต้น
- **common-functions** ตือ project ที่รันไ้ด้ทั้ง ใน  browser และ nodejs environemnt

ตัวอย่าง การสร้าง api-function และ ui-functions
```bash
# param1=ชื่อ workspace
# param2=ให้กำนดว่า เป็น api หรือ ui ตามต้องการ

# pwd is folder workspace-template
bash script-generator/new-functions.sh gu-example-system ui

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-functions.sh gu-example-system ui

```

ตัวอย่าง การสร้าง common-functions
```bash
# param1=ชื่อ workspace

# pwd is folder workspace-template
bash script-generator/new-functions.sh gu-example-system 

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

# pwd is folder workspace-template
bash script-generator/new-basetypes.sh gu-example-system ui-router

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

#### ก่อน push commit project Bastype
ให้รันคำสั่ง เพื่อสร้าง export path ใน package.json
```bash
# จะ export ทุก path ที่มี file index.ts
pnpm gen:exports
```
โครงสร้าง folder ใน source ดังนี้
![image](assets/Screenshot%202568-01-06%20at%2019.25.53.png)

จะได้ผลลัพ ใน package.json ดังนี้
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


**param1=ชื่อ workspace** เช่น gu-example-system
**param2=ชื่อ scope_name** ถ้าต้องการสร้าง project ภายใน scope folder ให้ใส่ค่าเป็น shared-webapi

```bash
# pwd is folder workspace-template
bash script-generator/new-plugin-fastify.sh gu-example-system 

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-plugin-fastify.sh gu-example-system 

```

