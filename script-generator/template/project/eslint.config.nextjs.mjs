// packages/nextjs-app/eslint.config.mjs
import rootConfig from '../../root-eslint.config.mjs';
import js from '@eslint/js';
import nextPlugin from '@next/eslint-plugin-next';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import tseslint from '@typescript-eslint/eslint-plugin';
import jestPlugin from 'eslint-plugin-jest';

export default [
  {
    ...rootConfig,
    files: ['**/*.ts', '**/*.tsx'],
    ignores: ['**/*.test.ts', '**/*.test.tsx'], // Ignore test files for main rules
    plugins: {
      '@typescript-eslint': tseslint,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
      '@next/next': nextPlugin,
      'jest': jestPlugin
    },
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
      react: {
        version: 'detect'
      },
      jest: {
        version: 29 // specify your Jest version
      }
    },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true
        }
      }
    }
  },
  // Test files config
  {
    files: ['**/*.test.ts', '**/*.test.tsx'],
    plugins: {
      'jest': jestPlugin,
      '@typescript-eslint': tseslint
    },
    rules: {
      ...rootConfig.rules,
      '@typescript-eslint/no-explicit-any': 'off', // Often needed in tests
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