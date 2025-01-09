// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config}  */

import type {Config} from 'jest';


import baseConfig from '../../../../jest.config.api-store-prisma';

// console.log("baseRootDir",baseConfig.rootDir)
// console.log("cwd=>",process.cwd())
// console.log("__dirname=>",__dirname)

const featureConfig: Config = {
  rootDir: __dirname,
  ...baseConfig,
  moduleNameMapper: {

    '^@funny-data-store-prisma/(.*)$': '<rootDir>/src/$1',

  },
}
// console.log("featureRootDir",featureConfig.rootDir)

export default featureConfig;