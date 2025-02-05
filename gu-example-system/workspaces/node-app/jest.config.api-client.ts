// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config} */
// import path from "path"
import type { Config } from 'jest';
import path from 'path'
import baseConfig from './jest.config.base';

// const  rd= path.join(__dirname, 'coverage',path.relative(__dirname, process.cwd())),
const apiClientConfig: Config = {
  ...baseConfig,
  // rootDir: process.cwd(),
  testEnvironment: 'node',

  testMatch: ['**/*.spec.*', '**/*.test.*'],

  collectCoverageFrom: [
    '**/*.logic*.{ts,tsx}',
    '**/*logic*/*.{ts,tsx}',
    '**/*command*/**/*.{ts,tsx}',
    '**/*query*/**/*.{ts,tsx}',
    '!**/mocks/**',
    '!**/types/**',
    '!**/*.types.*',
    '!**/*.model.*',
    '!**/index.*',
    '!**/*.d.ts',
  ],
  moduleNameMapper: {
    '^@/(.*)$': path.resolve(__dirname, './$1'), // refs to node-app folder
    '^@root/(.*)$': path.resolve(__dirname, '../../$1'), // refs to root workspace (gu-example-system)
  },

  // setupFilesAfterEnv: ['<rootDir>/src/test/setup.ts'],
  setupFilesAfterEnv: ['<rootDir>/src/setupTest.ts'],
  testPathIgnorePatterns: [
    '<rootDir>/node_modules/',
    '<rootDir>/dist/'
  ],
  // ถ้าระบุ tsconfig ที่ต้องการใน transform กับ ts-jest จะต้อง ignore rule TS5098
  // เพราะจะ error TS5098: Option 'resolvePackageJsonExports' can only be used when 'moduleResolution' is set to 'node16', 'nodenext', or 'bundler'.
  // ถึงแม้จะ config tsconfig ถูกต้องแล้วก็ตาม คาดว่าน่าจะเป็น bug ของ ts-jest กับ typescript
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

export default apiClientConfig;