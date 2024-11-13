// packages/api/eslint.config.mjs
import rootConfig from '../../root-eslint.config.mjs';
import tseslint from '@typescript-eslint/eslint-plugin';
import jestPlugin from 'eslint-plugin-jest';

export default [
  {
    ...rootConfig,
    files: ['**/*.ts'],
    ignores: ['**/*.test.ts'],
    plugins: {
      '@typescript-eslint': tseslint,
      'jest': jestPlugin
    },
    rules: {
      ...rootConfig.rules,
      '@typescript-eslint/explicit-function-return-type': 'error',
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',
      '@typescript-eslint/await-thenable': 'error',
      'no-return-await': 'off',
      '@typescript-eslint/return-await': 'error'
    },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: './tsconfig.json',
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    }
  },
  // Test files config
  {
    files: ['**/*.test.ts'],
    plugins: {
      'jest': jestPlugin,
      '@typescript-eslint': tseslint
    },
    rules: {
      ...rootConfig.rules,
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-non-null-assertion': 'off',
      'jest/expect-expect': 'error',
      'jest/no-conditional-expect': 'error',
      'jest/valid-title': 'error',
      'jest/prefer-strict-equal': 'warn'
    },
    languageOptions: {
      globals: {
        jest: true,
        it: true,
        expect: true,
        describe: true,
        beforeEach: true,
        afterEach: true
      }
    }
  }
];