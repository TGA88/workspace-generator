// storybook-host/tailwind.config.mjs
import baseConfig from '../../root-tailwind.config.mjs'

/** @type {import('tailwindcss').Config} */
export default {
  ...baseConfig,
  // important: '#storybook-root',
  prefix: "fos-",
  content: [
    ...baseConfig.content,
    "../../libs/feature-*/lib/**/*.{js,jsx,ts,tsx}",
    // "./src/**/*.{js,jsx,ts,tsx}",
    // "./stories/**/*.{js,jsx,ts,tsx}"
  ]
}

