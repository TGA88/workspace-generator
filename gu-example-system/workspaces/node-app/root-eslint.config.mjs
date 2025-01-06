// // Falt config  System for eslint version 8.x above
// // root-eslint.config.mjs

// import js from '@eslint/js';
// import tseslint from '@typescript-eslint/eslint-plugin';
// import * as tsParser from '@typescript-eslint/parser';
// import prettier from 'eslint-config-prettier';

// // // วิธีที่ 1: แยก prettier config เป็น object สุดท้าย
// // export const prettierConfig = {
// //   files: ['**/*.{js,jsx,ts,tsx,mjs,cjs}'],
// //   rules: {
// //     ...prettier.rules
// //   }
// // };

// // วิธีที่ 2: สร้าง function สำหรับ base config
// export function createBaseConfig({ tsConfigPath = './tsconfig.json' } = {}) {
//   return [
//     // ESLint recommended config
//     js.configs.recommended,

//     // TypeScript config
//     {
//       files: ['**/*.{ts,tsx}'],
//       plugins: {
//         '@typescript-eslint': tseslint,
//       },
//       languageOptions: {
//         parser: tsParser,
//         parserOptions: {
//           project: tsConfigPath,
//           ecmaVersion: 'latest',
//           sourceType: 'module',
//           ecmaFeatures: {
//             jsx: true,
//           },
//         },
//       },
//       rules: {
//         '@typescript-eslint/no-unused-vars': [
//           'error',
//           {
//             argsIgnorePattern: '^_',
//             varsIgnorePattern: '^_',
//           },
//         ],
//         '@typescript-eslint/no-explicit-any': 'warn',
//         'no-console': 'warn',
//       },
//     },

//     // Prettier config (ต้องอยู่ท้ายสุดเสมอ)
//     {
//       files: ['**/*.{js,jsx,ts,tsx,mjs,cjs}'],
//       rules: {
//         ...prettier.rules,
//       },
//     },
//   ];
// }

// root-eslint.config.mjs
import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import * as tsParser from '@typescript-eslint/parser';
import prettier from 'eslint-config-prettier';
import globals from 'globals';

export function createBaseConfig({ tsConfigPath = './tsconfig.json' } = {}) {
  return [
    // เทียบเท่ากับ file .eslintignore เดิม
    {
      ignores: ['**/node_modules/**', '**/dist/**', '**/.next/**'],
    },
    // JavaScript base config
    js.configs.recommended,

    // TypeScript base config
    {
      // กำหนดว่าจะใช้กับไฟล์อะไรบ้าง
      files: ['**/*.{ts,tsx,mts,cts}'],
      // กำหนด TypeScript parser และ options
      languageOptions: {
        parser: tsParser,
        parserOptions: {
          // project => รองรับการใช้ References และถ้ารู้ที่อยู่ tsconfig ที่ชัดเจนใช้วิธีนี้ดีกว่า เพราะ set ง่าย
          project: tsConfigPath,
          // // projectService มีคว่มยืดหยุ่นในการ scan หา tsconfig จาก cwd path และยังสามารถ optimization memoryได้ (สามารถใช้ร่วมกับ projectได้ โดย ปิด cwd เมื่อใช้ project ระุบุ tsconfig path)
          projectService: {
            // cwd: process.cwd(),
            skipLoadingLibrary: true, // optimize performance เร็วขึ้นเพราะไม่ต้องโหลด .d.ts files เหมาะกับการใช้ ESLint ที่ไม่ต้องการ type checking เต็มรูปแบบ
            matchingStrategy: 'recursive', // fallback strategy  ค้นหาขึ้นไปเรื่อยๆ จนเจอไฟล์
            // references: true  // เพิ่ม option นี้ ถ้าต้องการใช้ references path ใน tsconfig ด้วย
          },
          ecmaVersion: 2022,
          sourceType: 'module',
          ecmaFeatures: {
            jsx: true,
          },
        },
        // เพิ่ม globals สำหรับ browser environment
        globals: {
          ...globals.browser, // จะได้ window, document, localStorage, etc. ทำให้ eslint ไม่ฟ้อง error
          ...globals.node,
          ...globals.jest, // Config สำหรับ jest (สำหรับ test ใน nodejs จะได้รู้จัก describe,it,test,beforeAll,beforeEach,afterAll,afterEach)
        },
      },
      // กำหนด plugins
      plugins: {
        '@typescript-eslint': tseslint,
      },
      // กำหนด rules
      rules: {
        // ปิด ESLint rule ที่ conflict กับ @typescript-eslint
        'no-unused-vars': 'off',

        // TypeScript rules
        '@typescript-eslint/no-explicit-any': 'warn',
        '@typescript-eslint/explicit-function-return-type': 'off',
        '@typescript-eslint/no-unused-vars': [
          'error',
          {
            argsIgnorePattern: '^_',
            varsIgnorePattern: '^_',
            caughtErrorsIgnorePattern: '^_'
          },
        ],
      },
    },

    // Config สำหรับไฟล์ configs ที่เป็น TypeScript
    {
      files: ['**/*.config.{ts,mts}', '**/jest.config.{ts,mts}'],
      languageOptions: {
        parser: tsParser,
        parserOptions: {
          // project => รองรับการใช้ References และถ้ารู้ที่อยู่ tsconfig ที่ชัดเจนใช้วิธีนี้ดีกว่า เพราะ set ง่าย
          project: tsConfigPath,
          // // projectService มีคว่มยืดหยุ่นในการ scan หา tsconfig จาก cwd path และยังสามารถ optimization memoryได้ (สามารถใช้ร่วมกับ projectได้ โดย ปิด cwd เมื่อใช้ project ระุบุ tsconfig path)
          projectService: {
            // cwd: process.cwd(),
            skipLoadingLibrary: true, // optimize performance เร็วขึ้นเพราะไม่ต้องโหลด .d.ts files เหมาะกับการใช้ ESLint ที่ไม่ต้องการ type checking เต็มรูปแบบ
            matchingStrategy: 'recursive', // fallback strategy  ค้นหาขึ้นไปเรื่อยๆ จนเจอไฟล์
            // references: true  // เพิ่ม option นี้ ถ้าต้องการใช้ references path ใน tsconfig ด้วย
          },
          ecmaVersion: 2022,
          sourceType: 'module',
        },
        globals: {
          ...globals.node, // Config สำหรับ Node.js code (เช่น config files)
        },
      },
    },
    // แยก config สำหรับไฟล์ test โดยเฉพาะ
    {
      files: ['**/*.test.ts', '**/*.test.tsx', '**/*.spec.ts', '**/*.spec.tsx'],
      languageOptions: {
        globals: {
          ...globals.jest, // เพิ่ม jest globals
        },
      },
    },
    // Prettier config (ต้องอยู่ท้ายสุด)
    {
      files: ['**/*.{js,jsx,ts,tsx,mts,cts}'],
      rules: {
        ...prettier.rules,
      },
    },
  ];
}
