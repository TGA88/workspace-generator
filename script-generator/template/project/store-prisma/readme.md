## Project ต้องการ Package ดังนี้ กรณีไม่ได้ ใช้ workspace

**dependencies**
```json
// ควรปรับเป็น peer เพราะ webapi ที่นำไปใช้ควรติดpackage นี้ 
"@inh-lib/common": "^1.0.7",
"@inh-lib/ddd": "^1.0.1",
"tslib": "^2.3.0",
// ส่วน ตัว prisma ควรเป็น peer เพราะ ใ้ช้ แค่ gen sql script ตอน coding เท่านั้น ส่วนตอน รันใน Docker ใช้ liquibase
"@prisma/client": "^5.6.0",
"prisma": "^5.6.0"
// prisma-client ที่ gen จาก schema file จะถูก tsup bundle ใน code เลย เพราะ ไม่ได้ติดเป็น deppendency ใน package.json file
```

**devDependencies**
```json

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้
// =======

// type
"@types/jest": "^29.5.14",
"@types/node": "^22.9.0",

// test tools
"jest": "^29.7.0",
"jest-config": "^29.7.0",
"ts-jest": "^29.2.5",
"ts-node": "^10.9.2",
"jest-mock-extended": "^3.0.7"

// build tools
"typescript": "^5.6.3",
"tsup": "^6.7.0",


// dev tools
"tsc-watch": "^6.2.0"

// editor devtools
"prettier": "^3.3.3",
"eslint": "^9.14.0",
"eslint-config-prettier": "^9.1.0",
"@typescript-eslint/eslint-plugin": "^8.14.0",
"@typescript-eslint/parser": "^8.14.0",
"eslint-plugin-jest": "^28.9.0",
```