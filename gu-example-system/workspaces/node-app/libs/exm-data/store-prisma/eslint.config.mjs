// libs/ui/eslint.config.mjs
import { createBaseConfig } from '../../../root-eslint.config.mjs';

export default [
  ...createBaseConfig({ tsConfigPath: './tsconfig.json' }),
  {
    files: ['**/*.ts'],
    ignores: ['**/*.test.ts'],
    rules: {
      
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-module-boundary-types': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',
      
    }
  }
];