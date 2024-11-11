# workspace-generator
script to create pnpm workspace boilerplate

ตัวอย่างการ สร้าง workspace
```bash
# pwd is folder workspace-template
# bash script-generator/template/create-workspace.sh [parameter1:workspace-folder] [programing-type]
bash script-generator/create-workspace.sh feedos-example-system node-app

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/create-workspace.sh feedos-example-system node-app

```

ตัวอย่างการ init system-workspace เพื่อ intall and config tools 
```bash
# pwd is folder workspace-template
bash script-generator/init-system.sh feedos-example-system node-app

# สำหรับ clone ไปใช้ให้ วาง folderไว้ ระดับเดียวกับที่ต้องการ สร้าง workspace
bash workspace-generator/script-generator/init-system.sh feedos-example-system node-app

```