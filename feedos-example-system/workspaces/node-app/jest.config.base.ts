// jest.config.base.ts
import type { Config } from 'jest';
import { defaults } from 'jest-config';
import path from "path";


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

  coverageProvider:"v8",

  
  coverageDirectory: path.join(__dirname, 'coverage',path.relative(__dirname, process.cwd())),
  // coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'json-summary','cobertura'],
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