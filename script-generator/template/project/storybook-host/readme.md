## Project ต้องการ Package ดังนี้ กรณีไม่ได้ ใช้ workspace

**dependencies**
```json

"react": "^18.3.1",
"react-dom": "^18.3.1",


// mui
"@emotion/react": "^11.13.3",
"@emotion/styled": "^11.13.0",
"@mui/icons-material": "^6.1.7",
"@mui/material": "^6.1.7",
"@mui/x-data-grid": "^7.22.2",
"@tanstack/react-query": "^5.60.5",

// additional componnents 
"react-floater": "^0.9.4",
"react-joyride": "^2.9.2",

// common lib use both api and frontend
"luxon": "^3.4.4",
"axios": "^1.7.2",

```

**devDependencies**
```json

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้
"@types/luxon": "^3.4.2",

// type
"@types/react": "^18.3.12",
"@types/react-dom": "^18.3.1",

// test tools
"@storybook/test": "^8.0.0",
"msw": "^2.6.4",
"msw-storybook-addon": "^2.0.4",


// build tools
"typescript": "^5.6.3",
"vite": "^5.4.11",
"storybook": "^8.0.0",


// dev tools
"@storybook/react": "^8.0.0",
"@storybook/addon-essentials": "^8.0.0",
"@storybook/addon-interactions": "^8.0.0",
"@storybook/blocks": "^8.0.0",

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้
"autoprefixer": "^10.4.20",
"tailwindcss": "^3.4.15",
"postcss": "^8.4.49",

// editor tools
"ts-node": "^10.9.2",
"prettier": "^3.3.3",
"eslint": "^9.14.0",
"eslint-config-prettier": "^9.1.0",
"@typescript-eslint/eslint-plugin": "^8.14.0",
"@typescript-eslint/parser": "^8.14.0",
"eslint-plugin-react": "^7.37.2",
"eslint-plugin-react-hooks": "^5.0.0",
```

---
# Strorybook Project 
เป็น Project สำหรับ ใช้ run Feature และ UI Component ตอน Development

คำสั่ง ของ Project
```bash
#  cd ไปที่ project ก่อน

# คำสั่ง รัน ที่ local 
pnpm storybook

# คำสั่งbuild สำหรับ ในไป deploy
pnpm build-storybook

```