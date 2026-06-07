// patch-template-exports.mjs — ใช้ครั้งเดียวตอนปรับ template (เก็บไว้เป็นหลักฐาน/ใช้ซ้ำเมื่อเพิ่ม template ใหม่)
// เพิ่ม "development" condition (ชี้ source) ไว้บนสุดของทุก exports entry + ตั้ง sideEffects:false
import fs from 'node:fs';
import path from 'node:path';

const ROOT = new URL('../template/project/', import.meta.url).pathname;

// [template path, source dir, frontend(.tsx fallback)]
const TARGETS = [
  ['api-core/package.json', 'src', false],
  ['api-service/package.json', 'src', false],
  ['api-client/package.json', 'src', false],
  ['store-prisma/package.json', 'src', false],
  ['api-plugin-fastify/package.json', 'src', false],
  ['functions/package.json', 'src', false],
  ['base-types/package.json', 'src', false],
  ['features/package.json', 'lib', true],
  ['ui-common/package.json', 'lib', true],
];

function devTarget(value, srcDir, frontend) {
  let v = value.replace(/^\.\/dist\//, `./${srcDir}/`);
  if (frontend) {
    // ไฟล์ frontend อาจเป็น .tsx หรือ .ts — ใช้ fallback array (resolver ลองตามลำดับ)
    const base = v.replace(/\.(js|cjs|mjs)$/, '');
    return [`${base}.tsx`, `${base}.ts`];
  }
  return v.replace(/\.(mjs|js|cjs)$/, '.ts');
}

for (const [rel, srcDir, frontend] of TARGETS) {
  const file = path.join(ROOT, rel);
  if (!fs.existsSync(file)) { console.log('skip (not found):', rel); continue; }
  const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!pkg.exports) { console.log('skip (no exports):', rel); continue; }
  const out = {};
  for (const [key, val] of Object.entries(pkg.exports)) {
    if (val && typeof val === 'object' && !Array.isArray(val)) {
      const base = val.import || val.require || val.default;
      // "development" ต้องเป็น key แรก — condition แรกที่ match ชนะ
      out[key] = { development: devTarget(base, srcDir, frontend), ...val };
    } else {
      out[key] = val;
    }
  }
  pkg.exports = out;
  pkg.sideEffects = false; // ให้ bundler ฝั่ง consumer tree-shake ได้
  fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + '\n');
  console.log('patched:', rel);
}
console.log('DONE');
