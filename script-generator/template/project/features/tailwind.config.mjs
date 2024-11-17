// libs/ui/tailwind.config.mjs
import rootConfig from '../../tailwind.config.mjs'

export default {
  ...rootConfig,
  content: [
    './src/**/*.{js,ts,jsx,tsx}',
  ],
}