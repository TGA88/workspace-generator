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

## Lib Feature
ตัวอย่างการ generate project type feature
```bash
# pwd is folder workspace-template
bash script-generator/new-feature.sh feedos-example-system ui-foundations-mui

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/new-feature.sh feedos-example-system ui-foundations-mui

```

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