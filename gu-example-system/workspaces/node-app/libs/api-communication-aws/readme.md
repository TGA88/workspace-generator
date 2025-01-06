## Project ต้องการ Package ดังนี้ กรณีไม่ได้ ใช้ workspace

**dependencies**
```json

"@aws-sdk/client-sns": "^3.616.0",
"@aws-sdk/client-sqs": "^3.616.0"
"tslib": "^2.3.0",

// common lib use both api and frontend
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
"tsup": "^8.1.0",

// dev tools
// =========


// editor tools
"prettier": "^3.3.3",
"eslint": "^9.14.0",
"eslint-config-prettier": "^9.1.0",
"@typescript-eslint/eslint-plugin": "^8.14.0",
"@typescript-eslint/parser": "^8.14.0",
"eslint-plugin-jest": "^28.9.0",

```

