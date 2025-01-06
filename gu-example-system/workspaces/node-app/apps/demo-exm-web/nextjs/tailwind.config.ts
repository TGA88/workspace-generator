// storybook-host/tailwind.config.mjs
import baseConfig from '../../../root-tailwind.config.mjs'
import { createBase4Spacing } from './base4-spacing.mjs'

/** @type {import('tailwindcss').Config} */
export default {
  ...baseConfig,
  // important: '#storybook-root',
  prefix: "fos-",
  content: [
    ...baseConfig.content,
    "../../libs/**/feature-*/**/*.{js,jsx,ts,tsx}",
    './node_modules/**/feature-*/**/*.js',
    // "./src/**/*.{js,jsx,ts,tsx}",
    // "./stories/**/*.{js,jsx,ts,tsx}"
  ],
  theme: {
    extend: {
      spacing: createBase4Spacing(),
    },
  },
}

