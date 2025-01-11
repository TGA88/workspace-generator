// libs/ui/eslint.config.mjs
import { createBaseConfig } from '../../../root-eslint.config.mjs';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import globals from "globals";

export default [
  ...createBaseConfig({ tsConfigPath: './tsconfig.json' }),

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
  }
];