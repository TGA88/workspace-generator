// apps/web/eslint.config.mjs
import rootConfig from '../../root-eslint.config.mjs';
import js from '@eslint/js';
import nextPlugin from '@next/eslint-plugin-next';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import tseslint from '@typescript-eslint/eslint-plugin';

export default [
  {
    ...rootConfig,
    files: ['**/*.ts', '**/*.tsx'],
    ignores: ['**/*.test.ts', '**/*.test.tsx'],
    plugins: {
      '@typescript-eslint': tseslint,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
      '@next/next': nextPlugin,
      'prettier': require('eslint-plugin-prettier')
    },
    extends: [
      ...rootConfig.extends,
      'plugin:react/recommended',
      'plugin:react-hooks/recommended',
      'prettier'
    ],
    rules: {
      ...rootConfig.rules,
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      '@typescript-eslint/no-unused-vars': ['error', { 
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_'
      }],
      '@next/next/no-html-link-for-pages': 'error'
    },
    settings: {
      ...rootConfig.settings,
      react: {
        version: 'detect'
      }
    }
  }
];