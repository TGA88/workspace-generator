## Project ต้องการ Package ดังนี้ กรณีไม่ได้ ใช้ workspace

**dependencies**
```json

"@inh-lib/common": "^1.0.7",
"@inh-lib/ddd": "^1.0.1",
"tslib": "^2.3.0",
"zod": "^3.24.1"


// common lib can be used both api and frontend
"dotenv": "^16.4.5",

```

**devDependencies**
```json

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้
// =======

//  type 
"@types/jest": "^29.5.14",
"@types/node": "^22.9.0",

// test tools
"jest": "^29.7.0",
"jest-config": "^29.7.0",
"ts-jest": "^29.2.5",
"ts-node": "^10.9.2",

// build tools
"typescript": "^5.6.3",
"tsup": "^6.7.0",

// dev tools
// ========

// editor devtools
"prettier": "^3.3.3",
"eslint": "^9.14.0",
"eslint-config-prettier": "^9.1.0",
"@typescript-eslint/eslint-plugin": "^8.14.0",
"@typescript-eslint/parser": "^8.14.0",
"eslint-plugin-jest": "^28.9.0",
```