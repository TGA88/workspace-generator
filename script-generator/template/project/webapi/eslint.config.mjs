// apps/webapi/eslint.config.mjs (Fastify)
import rootConfig from '../../root-eslint.config.mjs';
import tseslint from '@typescript-eslint/eslint-plugin';
import eslintPluginPrettier from 'eslint-plugin-prettier';

export default [
  {
    ...rootConfig,
    files: ['**/*.ts'],
    ignores: ['**/*.test.ts'],
    plugins: {
      '@typescript-eslint': tseslint,
    },
    extends: [
      ...rootConfig.extends,
      'prettier'
    ],
    rules: {
      ...rootConfig.rules,
      '@typescript-eslint/explicit-function-return-type': 'error',
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',
      '@typescript-eslint/await-thenable': 'error',
      'no-return-await': 'off',
      '@typescript-eslint/return-await': 'error'
    }
  }
];