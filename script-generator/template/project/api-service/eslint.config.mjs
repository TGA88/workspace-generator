// libs/typescript/eslint.config.mjs (Typescript Library)
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
      'prettier': eslintPluginPrettier
    },
    extends: [
      ...rootConfig.extends,
      'prettier'
    ],
    rules: {
      ...rootConfig.rules,
      '@typescript-eslint/explicit-function-return-type': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-module-boundary-types': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',
      'import/no-default-export': 'error'
    }
  }
];