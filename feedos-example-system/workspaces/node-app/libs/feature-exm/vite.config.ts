// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import dts from 'vite-plugin-dts'
import { libInjectCss } from 'vite-plugin-lib-inject-css'
import { nodeExternals } from 'rollup-plugin-node-externals'
import type { Plugin, RenderedChunk, NormalizedOutputOptions } from 'rollup'
import { extname, relative, resolve,dirname } from 'path';
import { fileURLToPath } from 'node:url';
import { glob } from 'glob';



const preserveUseClientDirective = (): Plugin => {
  return {
    name: 'preserve-use-client',
    renderChunk(
      code: string, 
      chunk: RenderedChunk,
      _options: NormalizedOutputOptions
    ) {
      // เพิ่ม this context
      const moduleInfo = this.getModuleInfo(chunk.facadeModuleId as string);
      const sourceCode = moduleInfo?.code || '';
      
      if (sourceCode.includes("'use client'") || sourceCode.includes('"use client"')) {
        return `'use client';\n${code}`;
      }
      return code;
    }
  };
};

// ใน ESM เราไม่สามารถใช้ __dirname ได้โดยตรง เพราะเป็น CommonJS 
// วิธีที่ 1: ใช้ import.meta.url
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
// วิธีที่ 2: ใช้ URL และ fileURLToPath
// ตัวอย่าง rootDir: dirname(fileURLToPath(import.meta.url)),
// วิธีที่ 3: ใช้ process.cwd() สำหรับ root directory ของ project
// ตัวอย่าาง   rootDir: process.cwd(),

export default defineConfig({
  plugins: [
    react(),
    // dts({ 
    //   include: ['lib'],
    //   exclude: ['lib/**/*.test.*','lib/**/*.spec.*', 'src/**/*.stories.*'],
    // }),
    dts({tsconfigPath: 'tsconfig.build.json',outDir: 'dist/types', }),
    preserveUseClientDirective(),
    libInjectCss(),
    {
      ...nodeExternals({
        devDeps: true,
        peerDeps: true,
      }),
      enforce: 'pre'
    }
  ],
  build: {
    lib: {
      entry: resolve(__dirname, 'lib/main.ts'),
      formats: ['es'],
      fileName: (format) => `main.${format}.js`
    },
    rollupOptions: {
      input: Object.fromEntries(
        glob
          .sync('lib/**/*.{ts,tsx}')
          .filter((file) => !file.endsWith('.test.ts'))
          .filter((file) => !file.endsWith('.test.tsx'))
          .filter((file) => !file.endsWith('.stories.tsx'))
          .map((file) => [
            // The name of the entry point
            // lib/nested/foo.ts becomes nested/foo
            relative('lib', file.slice(0, file.length - extname(file).length)),
            // The absolute path to the entry file
            // lib/nested/foo.ts becomes /project/lib/nested/foo.ts
            fileURLToPath(new URL(file, import.meta.url)),
          ]),
      ),
      output: {
        assetFileNames: 'assets/[name][extname]',
        entryFileNames: '[name].js',
        // preserveModules: true,
        // preserveModulesRoot: 'lib',
        // plugins: [preserveUseClientDirective()]
      }
    }
  }
})

