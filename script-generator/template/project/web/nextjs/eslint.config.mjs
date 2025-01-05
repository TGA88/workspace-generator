// libs/ui/eslint.config.mjs
import { createBaseConfig } from '../../../root-eslint.config.mjs';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import globals from "globals";
import nextPlugin from '@next/eslint-plugin-next';
import nextConfig from 'eslint-config-next';

export default [
  ...createBaseConfig({ tsConfigPath: './tsconfig.json' }),
  ...nextConfig.configs,  // นำ config ของ Next.js มาใช้
  {
    files: ['**/*.{jsx,tsx}'],
    plugins: {
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin
    },
    settings: {
      react: {
        version: 'detect'
      }
    },
    languageOptions: {
      globals: {
        ...globals.browser,
        // ...globals.commonjs, // ถ้าใช้ CommonJS modules
        JSX: 'readonly' // สำหรับ React JSX
      }
    },
    rules: {
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'react/display-name': 'error',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn'
    }
  },
   // เพิ่ม rules จาก next plugin
   {
    files: ['**/*.{js,jsx,ts,tsx}'],
    plugins: {
      '@next/next': nextPlugin
    },
    rules: {
      // ปิด rules จาก eslint-config-next
      '@next/next/no-img-element': 'off',
      '@next/next/no-html-link-for-pages': 'off',

      // เพิ่มหรือแก้ไข rules
      '@next/next/google-font-display': 'error',
      '@next/next/no-page-custom-font': 'warn',
      '@next/next/no-sync-scripts': 'error',
      '@next/next/no-unwanted-polyfillio': 'error',
    }
  },

  // config เฉพาะ page directory
  {
    files: ['pages/**/*.{js,jsx,ts,tsx}'],
    rules: {
      '@next/next/no-document-import-in-page': 'error',
      '@next/next/no-head-import-in-document': 'error',
    }
  },

  // config เฉพาะ app directory
  {
    files: ['app/**/*.{js,jsx,ts,tsx}'],
    rules: {
      '@next/next/no-head-element': 'error',
      '@next/next/no-before-interactive-script-outside-document': 'error',
    }
  }
];