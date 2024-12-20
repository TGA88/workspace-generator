import { defineConfig } from 'tsup';

export default defineConfig({
  // entry: ['src/index.ts', 'src/**/*.ts', 'src/**/*.tsx','!**/*test*/**'],
  entry: ['src/index.ts', 'src/**/index.ts', 'src/**/*.tsx','!**/*test*/**','!**/*.test.*','!**/*.spec.*'],
  format: ['cjs', 'esm'],
  splitting: true,
  sourcemap: true,
  clean: true,
  minify: true,
  dts: true,
  outDir: 'dist',
});
