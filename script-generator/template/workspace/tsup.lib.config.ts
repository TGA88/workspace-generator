import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts', 'src/**/*.ts', 'src/**/*.tsx','!**/*test*/**'],
  format: ['cjs', 'esm'],
  splitting: true,
  sourcemap: true,
  clean: true,
  minify: false, // lib ไม่ต้อง minify: build เร็วขึ้น debug ง่าย consumer จะ bundle+minify เองตอน release
  dts: true,
  outDir: 'dist',
});
