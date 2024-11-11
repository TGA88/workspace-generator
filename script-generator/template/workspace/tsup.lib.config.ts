import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts', 'src/**/*.ts', 'src/**/*.tsx','!**/*test*/**'],
  format: ['cjs', 'esm'],
  splitting: true,
  sourcemap: true,
  clean: true,
  minify: true,
  dts: true,
  outDir: 'dist',
});
