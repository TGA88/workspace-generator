// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config}  */

import type {Config} from 'jest';
import baseConfig from '../../jest.config.features';

console.log("baseRootDir",baseConfig.rootDir)
console.log("cwd=>",process.cwd())
console.log("__dirname=>",__dirname)

const featureConfig: Config = {
  rootDir: __dirname,
  ...baseConfig,
  // transform: {
  //   '^.+\\.tsx?$': [
  //     'ts-jest',
  //     {
  //       isolatedModules: true,
  //       // tsconfig: `${process.cwd()}/tsconfig.json`,
  //       // tsconfig: './tsconfig.json',
  //       tsconfig: '<rootDir>/tsconfig.json',
  //       // tsconfig: './tsconfig.node.json',
  //       diagnostics: {
  //         ignoreCodes: ['TS151001', 'TS5098'],
  //         // warnOnly: true,
  //         pretty: true
  //       }
  //     }
  //   ],
  //   '^.+\\.ts?$': [
  //     'ts-jest',
  //     {
  //       isolatedModules: true,
  //       // tsconfig: `${process.cwd()}/tsconfig.json`,
  //       // tsconfig: './tsconfig.node.json',
  //       tsconfig: '<rootDir>/tsconfig.json',
  //       diagnostics: {
  //         ignoreCodes: ['TS151001', 'TS5098'],
  //         // warnOnly: true,
  //         pretty: true
  //       }
  //     }
  //   ]
  // }
}
console.log("featureRootDir",featureConfig.rootDir)

export default featureConfig;