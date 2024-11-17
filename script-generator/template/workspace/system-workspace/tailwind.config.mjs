// tailwind.config.js -> tailwind.config.mjs
import defaultTheme from 'tailwindcss/defaultTheme.js'

export default {
  content: [
    "./apps/**/*.{js,ts,jsx,tsx}",
    "./libs/**/*.{js,ts,jsx,tsx}",
  ],
  corePlugins: {
    preflight: false,
  },
  important: '#root',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  }
}