// libs/ui/eslint.config.mjs
import { createBaseConfig } from '../../root-eslint.config.mjs';


export default [
  ...createBaseConfig({ tsConfigPath: './tsconfig.json' }),


];