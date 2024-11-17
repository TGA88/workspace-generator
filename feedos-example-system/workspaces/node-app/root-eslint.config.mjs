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
          // project => ไม่รองรับการใช้ References ใน tsconfig จะต้อง อ้างถึง tsconfig.xx.json ตัวที่ระบุfileที่ ต้องการให้ eslint ตรวจ
          // project: tsConfigPath,
          // projectService วิธีนี้รองรับ References ใน tsconfig
          projectService: {
            cwd: process.cwd(),
            skipLoadingLibrary: true,
            matchingStrategy: 'recursive',
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
          // project: tsConfigPath,
          projectService: {
            cwd: process.cwd(),
            skipLoadingLibrary: true,
            matchingStrategy: 'recursive',
          },
          ecmaVersion: 2022,
          sourceType: 'module',
        },
        globals: {
          ...globals.node // Config สำหรับ Node.js code (เช่น config files)
        }
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
