// jest.config.base.ts
import type { Config } from 'jest';
import { defaults } from 'jest-config';
import path from "path"; //ต้องset tsconfig compileroption{"esModuleInterop:true"} เพื่อให้ สามารถ ใช้คำสั่ง import path ซึ่ง package path ของ nodejs default เป็น commonjs ได้
 
const baseConfig: Config = {
  preset: 'ts-jest',
  verbose: true,
  moduleFileExtensions: [...defaults.moduleFileExtensions],
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        isolatedModules: true,
        diagnostics: {
          ignoreCodes: ['TS151001']
        }
      }
    ]
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{ts,tsx}',
    '!src/**/index.{ts,tsx}',
    '!src/**/*.test.{ts,tsx}'
  ],
  coverageDirectory: path.join(__dirname,'coverage',path.relative(__dirname, process.cwd())),
  coverageReporters: ['text', 'lcov', 'json-summary'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};

export default baseConfig;