// jest.config.base.ts
import type { Config } from 'jest';
import { defaults } from 'jest-config';
import path from "path";



const baseConfig: Config = {
  preset: 'ts-jest',
  verbose: true,
  moduleFileExtensions: [...defaults.moduleFileExtensions],
  // ถ้าไม่ได้ระบุ tsconfig ใน transform ts-jest จะค้นหา tsconfig ตามลำกดับ ดังนี้
  // 1. tsconfig.jest.json
  // 2. tsconfig.test.json
  // 3. tsconfig.json
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

  coverageProvider: "v8",


  coverageDirectory: path.join(__dirname, 'coverage', path.relative(__dirname, process.cwd())),
  // coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'json-summary', 'cobertura'],
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