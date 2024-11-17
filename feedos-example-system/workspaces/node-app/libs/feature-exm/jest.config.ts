

// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config} */
import type {Config} from 'jest';
import baseConfig from '../../jest.config.base';

const featureConfig: Config = {
  ...baseConfig,
  testEnvironment: 'node',
  testMatch: ['**/*.spec.*', '**/*.test.*'],
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],
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