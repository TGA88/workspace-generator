// root-eslint.config.mjs
import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import jestPlugin from 'eslint-plugin-jest';

export default {
  root: true,
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:jest/recommended',
    'prettier' // ใช้เพื่อ disable rules ที่ขัดแย้งกับ prettier เท่านั้น
  ],
  parser: '@typescript-eslint/parser',
  plugins: {
    '@typescript-eslint': tseslint,
    'jest': jestPlugin
    // ไม่ต้องใช้ eslint-plugin-prettier
  },
  rules: {
    // typescript rules
    'no-console': 'warn',
    '@typescript-eslint/no-unused-vars': ['error', { 
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_'
    }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn'
  }
};