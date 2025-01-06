# workspace-generator
script to create pnpm workspace boilerplate

## workspace
ตัวอย่างการ สร้าง workspace
```bash
# pwd is folder workspace-template
# bash script-generator/template/create-workspace.sh [parameter1:workspace-folder] [programing-type]
bash script-generator/create-workspace.sh feedos-example-system node-app

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/create-workspace.sh feedos-example-system node-app

```

## Initial package for System workspace
ตัวอย่างการ init system-workspace เพื่อ intall and config tools 
```bash
# pwd is folder workspace-template
bash script-generator/init-system.sh feedos-example-system node-app

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/init-system.sh feedos-example-system node-app

```
ระหว่าง install package จะมีคถามดังนี้ ให้ตอบ skip-now
![image](assets/Screenshot%202567-12-23%20at%2016.51.52.png)

## Storybook host

### Create
ตัวอย่างการ generate project type storybook-host
```bash
# pwd is folder workspace-template
bash script-generator/new-storybook.sh feedos-example-system example

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-storybook.sh feedos-example-system example

```

### Update
ตัวอย่างการ update project storybook-host เพื่อ update reference lib feature
```bash
# pwd is folder workspace-template
bash script-generator/update-sb.sh feedos-example-system example

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/update-sb.sh feedos-example-system example

```
---

# System Workspace
## Frontend Project

### Web-Nextjs
**param1=ชื่อ workspace** เช่น feedos-example-system
**param2=ชื่อ webproject** เช่น demo-exm-web
ตัวอย่างการ generate project type web nextjs
```bash
# pwd is folder workspace-template
bash script-generator/new-web.sh feedos-example-system demo-exm-web

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-web.sh feedos-example-system demo-exm-web

```
### Feature-Lib
ตัวอย่างการ generate project type feature
**param1=ชื่อ workspace** เช่น feedos-example-system
**param2=ชื่อ fetaure** เช่น feature-funny
```bash
# pwd is folder workspace-template
bash script-generator/new-feature.sh feedos-example-system feature-funny

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh feedos-example-system feature-funny

```

### ui-components
เป็น project ที่ component ,customhooks ที่เอาไว้แชร์ เฉพาะภายใน scope ของ system worksapce เท่านั้น ซึ่งจะไม่ deploy ขึ้น npm
**ใช้ new-feature.sh แต่ไม่ระบุ project name จะได้ project ui-components**

**param1=ชื่อ workspace** เช่น feedos-example-system
```bash
# pwd is folder workspace-template
bash script-generator/new-feature.sh feedos-example-system 

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh feedos-example-system 

```

### web-config

เป็น project ที่ config สำหรับ webproject และ เอาไว้ share ให้ feature project ใช้งานด้วย

**ใช้ new-feature.sh  แต่ให้ระบุ suffix project name เช่น demo-exm-web-config**

**param1=ชื่อ workspace**
**param2=ชื่อ webproject**
```bash
# pwd is folder workspace-template
bash script-generator/new-webconfig.sh feedos-example-system demo-exm-web

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-webconfig.sh feedos-example-system demo-exm-web

```

---
## API Project
### API-CORE
ตัวอย่างการ update project api-core  สำหรับเก็บ abstract layer เช่น interface,type,repository,และ BusinessLogic ที่ต้องการ Share ระหว่าง DataLayer และ ServiceLayer
```bash
# param1=ชื่อ workspace
# param2=ชื่อ api

# pwd is folder workspace-template
bash script-generator/new-apicore.sh feedos-example-system sample-api

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-apicore.sh feedos-example-system sample-api

```
### API-Service
ตัวอย่างการ update project api-service สำหรับ Provide Action ตาม Business Requirement

```bash
# param1=ชื่อ workspace
# param2=ชื่อ api

# pwd is folder workspace-template
bash script-generator/new-apiservice.sh feedos-example-system sample-api

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-service.sh feedos-example-system sample-api

```

### API-StorePrisma
ตัวอย่างการ update project api-store-prisma สำหรับ Provide data layer และ schema model สำหรับ prismaorm

```bash
# param1=ชื่อ workspace
# param2=ชื่อ database schema

# pwd is folder workspace-template
bash script-generator/new-storeprisma.sh feedos-example-system demo

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-storeprisma.sh feedos-example-system demo

```

### Web-API
ตัวอย่างการ สร้าง Project apps ประเถท webapi

```bash
# param1=ชื่อ workspace
# param2=ชื่อ projectname เช่น demo-exm-webapi

# pwd is folder workspace-template
bash script-generator/new-webapi.sh feedos-example-system demo-exm-webapi

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-webapi.sh feedos-example-system demo-exm-webapi

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
bash script-generator/new-uicommon.sh feedos-example-system 

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-uicommon.sh feedos-example-system 

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
bash script-generator/new-functions.sh feedos-example-system ui

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-functions.sh feedos-example-system ui

```

ตัวอย่าง การสร้าง common-functions
```bash
# param1=ชื่อ workspace

# pwd is folder workspace-template
bash script-generator/new-functions.sh feedos-example-system 

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-functions.sh feedos-example-system 

```

### base-types
เป็น Project ที่เก็บ Types สำหรับ นำไปใช้งาน และ จะต้องมี  project implementation ด้วย เช่น
- base-types project คือ ui-router  และ implementation project คือ ui-router-nextjs
- base-types project คือ api-communication  และ implementation project คือ api-communication-aws
    - api-communication จะมี producerItf และ senderItf ให้ใช้งาน

ตัวอย่าง การสร้าง base-types
```bash
# param1=ชื่อ workspace
# param2= ชื่อ base-types  ที่ต้องการ

# pwd is folder workspace-template
bash script-generator/new-basetypes.sh feedos-example-system ui-router

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-functions.sh feedos-example-system ui-router

```
> หลังสร้าง BaseType Project แล้ว ให้ลบ คำสั่ง test ใน package.json ออกให้หมด


**ส่วน การ implementation Project**
แนะนำให้ใช้ แบบเดียวกันกับ baseTypes แต่ ให้ Clear โครงสร้าง ใน folder src ก่อน และ สร้าง project ได้ตามต้องการ

### ก่อน push commit project Bastype
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

## fastify-plugins
### ยังไม่ได้สร้าง 

