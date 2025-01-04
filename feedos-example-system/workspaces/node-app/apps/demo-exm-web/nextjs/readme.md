## Project ต้องการ Package ดังนี้ กรณีไม่ได้ ใช้ workspace

**dependencies**
```json

"next": "14.2.20",
"react": "18.3.1",
"react-dom": "18.3.1",

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้
"react-floater": "^0.9.4",
"react-joyride": "^2.9.2",
"react-redux": "^9.1.0",
"@reduxjs/toolkit": "^2.2.2",
"@next/third-parties": "14.2.12",
"next-intl": "^3.23.5",
"@emotion/react": "^11.13.3",
"@emotion/styled": "^11.13.0",
"@mui/icons-material": "^6.1.7",
"@mui/material": "^6.1.7",
"@mui/x-data-grid": "^7.22.2",
"@tanstack/react-query": "^5.60.5",

// common lib use both api and frontend
"luxon": "^3.4.4",
"axios": "^1.7.2",

```

**devDependencies**
```json

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้
"@types/luxon": "^3.4.2",
"tailwindcss": "^3.4.15",
"autoprefixer": "^10.4.20",
"postcss": "^8.4.49",

// type
"@types/react": "^18.3.12",
"@types/react-dom": "^18.3.1",

// test tools
// =========

// build tools
"typescript": "^5.6.3",

// editor tools
"prettier": "^3.3.3",
"eslint": "^9.14.0",
"eslint-config-prettier": "^9.1.0",
"@typescript-eslint/eslint-plugin": "^8.14.0",
"@typescript-eslint/parser": "^8.14.0",
"eslint-plugin-react": "^7.37.2",
"eslint-plugin-react-hooks": "^5.0.0",
// ยังไม่ชัวว่า 2 ตัวนนี้ Nexjs ใช้ตัวไหน หรือใช้ทั้ง2
"eslint-config-next": "14.2.3",
"@next/eslint-plugin-next": "^15.0.3"


```