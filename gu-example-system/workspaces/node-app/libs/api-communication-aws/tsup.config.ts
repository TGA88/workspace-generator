import { defineConfig } from 'tsup';

export default defineConfig({
    entry: ['src/index.ts'],
    format: ['cjs', 'esm'],
    splitting: true,
    sourcemap: true,
    clean: true,
    minify: true,
    dts: true,
    outDir: 'dist',
    outExtension({ format }) {
        return {
          js: format === 'cjs' ? '.js' : '.mjs' // กำหนดนามสกุลไฟล์ตาม format
        }
      }
});
