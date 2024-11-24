// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config} */
// import path from "path"
import type { Config } from 'jest';
import baseConfig from './jest.config.base';

// const  rd= path.join(__dirname, 'coverage',path.relative(__dirname, process.cwd())),
const featureConfig: Config = {
  ...baseConfig,
  // rootDir: process.cwd(),

  // use jest-fixed-jsdom to fix msw v2 error Request/Response/TextEncoder is not defined (Jest)
  testEnvironment: 'jest-fixed-jsdom',
  testMatch: ['**/*.spec.*', '**/*.test.*'],

  collectCoverageFrom: [
    'lib/**/*.{ts,tsx}',
    '!**/*.d.ts',
    '!**/*.stories.{ts,tsx}',
    '!**/index.{ts,tsx}',
    '!**/*.test.{ts,tsx}',
    '!**/*.spec.{ts,tsx}'
  ],


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
        // tsconfig: `${process.cwd()}/tsconfig.json`,
        // tsconfig: './tsconfig.json',
        tsconfig: '<rootDir>/tsconfig.json',
        // tsconfig: './tsconfig.node.json',
        diagnostics: {
          ignoreCodes: ['TS151001', 'TS5098'],
          // warnOnly: true,
          pretty: true
        }
      }
    ],
    '^.+\\.ts?$': [
      'ts-jest',
      {
        isolatedModules: true,
        // tsconfig: `${process.cwd()}/tsconfig.json`,
        // tsconfig: './tsconfig.node.json',
        tsconfig: '<rootDir>/tsconfig.json',
        diagnostics: {
          ignoreCodes: ['TS151001', 'TS5098'],
          // warnOnly: true,
          pretty: true
        }
      }
    ]
  }
}

export default featureConfig;