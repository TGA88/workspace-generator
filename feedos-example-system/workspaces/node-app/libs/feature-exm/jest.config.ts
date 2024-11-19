// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config} */
import type {Config} from 'jest';
import baseConfig from '../../jest.config.base';

const featureConfig: Config = {
  ...baseConfig,
  // use jest-fixed-jsdom to fix msw v2 error Request/Response/TextEncoder is not defined (Jest)
  testEnvironment: 'jest-fixed-jsdom',
  testMatch: ['**/*.spec.*', '**/*.test.*'],
  moduleFileExtensions: ['ts', 'js', 'tsx', 'jsx','json', 'node'],

  // setupFilesAfterEnv: ['<rootDir>/src/test/setup.ts'],
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/dist/'
  ],
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        isolatedModules: true,
        tsconfig: '<rootDir>/tsconfig.json',
        // tsconfig: './tsconfig.node.json',
        diagnostics: {
          ignoreCodes: ['TS151001']
        }
      }
    ],
    '^.+\\.ts?$': [
        'ts-jest',
        {
          isolatedModules: true,
          tsconfig: '<rootDir>/tsconfig.json',
          // tsconfig: './tsconfig.node.json',
          diagnostics: {
            ignoreCodes: ['TS151001']
          }
        }
      ]
  }
}

export default featureConfig;