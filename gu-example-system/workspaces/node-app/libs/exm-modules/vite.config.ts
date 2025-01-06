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


const entries:Record<string, string> = glob.sync('*modules/**/main.ts').reduce((acc:Record<string, string>, path) => {
  const name = path.split('/').slice(-2)[0]; // get folder name
  acc[name] = resolve(__dirname, path) ;
  return acc;
}, {});

console.log(entries)

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
  resolve: {
    alias: {
      '@': resolve(__dirname, '../../'),
      '@root': resolve(__dirname, '../../../../'),
      '@exm-modules': resolve(__dirname, './lib'),
      '@feature-funny': resolve(__dirname, './lib/feature-funny')
    }
  },
  build: {
    // lib mode กับ format: 'es' การ minify จะไม่ minify whitespaces เพราะจะทำให้ pure annotations หายและส่งผลต่อ tree-shaking
    lib: {
      // entry: resolve(__dirname, '**/main.ts'),
      entry: entries,
      // formats: ['es','cjs'],
      formats: ['es'], //เราจะใช้ เฉพาะ es อย่างเดียว เพราะ react component ของเราจะนำไปใช้กับ รูปแบบ esm อย่างเดียวจึงไม่ต้อง compile format cjs
      // fileName: (format) => `main.${format}.js`
      fileName: (format) => `[name].${format === 'es' ? 'js' : 'cjs'}`
    },
    rollupOptions: {
      input: Object.fromEntries(
        glob
          .sync('lib/**/*.{ts,tsx}')
          .filter((file) => !file.match('/mocks/'))
          .filter((file) => !file.match('setupTest.*'))
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
        // entryFileNames: '[name].js', //ถ้าที่ build.lib มีการ set fileNameแล้ว จะใช้ตรงนั้นเป็น output name โดยที่ไม่ต้องSet entryFileNamesก็ได้
        // preserveModules: true,
        // preserveModulesRoot: 'lib',
        // plugins: [preserveUseClientDirective()]
      }
    }
  }
})

