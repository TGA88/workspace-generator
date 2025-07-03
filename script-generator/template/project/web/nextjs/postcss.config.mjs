/** @type {import('postcss-load-config').Config} */
import { join, dirname } from 'path'
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url); // get the resolved path to the file
const __dirname = dirname(__filename);
const config = {
  plugins: {
    // for tailwindcss version 3  
    // tailwindcss: {
    //   config: join(__dirname, 'tailwind.config.mjs'),
    // },
    '@tailwindcss/postcss': {
      config: join(__dirname, 'tailwind.config.mjs'),
    },
    autoprefixer: {},
  },
};

export default config;
