## Project ต้องการ Package ดังนี้ กรณีไม่ได้ ใช้ workspace

### สำหรับ Project Type Feature และ ui-component
**dependencies**
```json

"react": "^18.3.1",
"react-dom": "^18.3.1",

// additional package ลบได้ถ้าคิดว่าไมไ่ด้ใช้

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
"jest": "^29.7.0",
"jest-config": "^29.7.0",
"ts-jest": "^29.2.5",
"ts-node": "^10.9.2",
"jest-environment-jsdom": "^29.7.0",
"jest-fixed-jsdom": "^0.0.9",
"msw": "^2.6.4",
"identity-obj-proxy": "^3.0.0",
"@testing-library/react": "^16.0.1",
// หากต้องการ Test UIComponent ให้ ติด 2ตัวนี้ด้วย
// "@testing-library/jest-dom": "^6.6.3",
// "@testing-library/user-event": "^14.5.2",

// build tools
"typescript": "^5.6.3",
"vite": "^5.4.11",
"vite-plugin-dts": "^4.3.0",
"vite-plugin-lib-inject-css": "^2.1.1",
"vite-plugin-sass-dts": "^1.3.29"
"rollup": "^4.27.2",
"rollup-plugin-node-externals": "^7.1.3",
"rollup-plugin-preserve-directives": "^0.4.0",
"glob": "^11.0.0",
"globals": "^15.11.0",

// dev tools
"@storybook/react": "^8.0.0",
// ถ้าต้องการ Test Component ด้วยให้ติด package เพิ่มดังนี้
// "@storybook/test": "^8.0.0",


// editor tools
"prettier": "^3.3.3",
"eslint": "^9.14.0",
"eslint-config-prettier": "^9.1.0",
"@typescript-eslint/eslint-plugin": "^8.14.0",
"@typescript-eslint/parser": "^8.14.0",
"eslint-plugin-react": "^7.37.2",
"eslint-plugin-react-hooks": "^5.0.0",
```

---
# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type aware lint rules:

- Configure the top-level `parserOptions` property like this:

```js
export default tseslint.config({
  languageOptions: {
    // other options...
    parserOptions: {
      project: ['./tsconfig.node.json', './tsconfig.app.json'],
      tsconfigRootDir: import.meta.dirname,
    },
  },
})
```

- Replace `tseslint.configs.recommended` to `tseslint.configs.recommendedTypeChecked` or `tseslint.configs.strictTypeChecked`
- Optionally add `...tseslint.configs.stylisticTypeChecked`
- Install [eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react) and update the config:

```js
// eslint.config.js
import react from 'eslint-plugin-react'

export default tseslint.config({
  // Set the react version
  settings: { react: { version: '18.3' } },
  plugins: {
    // Add the react plugin
    react,
  },
  rules: {
    // other rules...
    // Enable its recommended rules
    ...react.configs.recommended.rules,
    ...react.configs['jsx-runtime'].rules,
  },
})
```
