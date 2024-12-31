// packages/api/jest.config.ts
// import type { Config } from 'jest';
/** @type {import('jest').Config}  */

import type {Config} from 'jest';


import baseConfig from '../../../jest.config.webapi';

// console.log("baseRootDir",baseConfig.rootDir)
// console.log("cwd=>",process.cwd())
// console.log("__dirname=>",__dirname)

const webApiConfig: Config = {
  rootDir: __dirname,
  ...baseConfig,
  moduleNameMapper: {

    '^@self/(.*)$': '<rootDir>/$1',

  },
}
// console.log("featureRootDir",featureConfig.rootDir)

export default webApiConfig;