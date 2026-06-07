// packages/api/jest.config.ts
// import type { Config } from 'jest';

/** @type {import('jest').Config}  */

import type {Config} from 'jest';


import baseConfig from '../../jest.config.features';

// console.log("baseRootDir",baseConfig.rootDir)
// console.log("cwd=>",process.cwd())
// console.log("__dirname=>",__dirname)

const featureConfig: Config = {
  rootDir: __dirname,
  ...baseConfig,
  moduleNameMapper: {
    ...(baseConfig.moduleNameMapper || {}),
    // บังคับให้ทุก import ใช้ react สำเนาเดียวกับของ project นี้
    // กัน dual-React (Cannot read properties of null reading 'useState') เมื่อ @testing-library อยู่ root
    '^react$': require.resolve('react'),
    '^react-dom$': require.resolve('react-dom'),
    '^react/jsx-runtime$': require.resolve('react/jsx-runtime'),

    '^@ui-exm/(.*)$': '<rootDir>/lib/$1',

  },
}
// console.log("featureRootDir",featureConfig.rootDir)

export default featureConfig;