#!/usr/bin/env bash
# update_alias_path.sh <package-name>
#
# เขียน alias ของ sub-module ใน ./lib/* ลง 4 ไฟล์ config ของ frontend lib:
#   tsconfig.json · tsconfig.build.json (compilerOptions.paths)
#   jest.config.ts (moduleNameMapper) · vite.config.ts (resolve.alias)
#
# v1.6.0 — เขียนใหม่จาก sed line-surgery เป็น brace-matching patch (node)
#   ของเดิมใช้ `sed` command `c\` แทนที่ "บรรทัด" ที่ match → พฤติกรรม BSD/GNU sed ต่างกัน
#   และไม่รู้จักขอบเขตของบล็อก ⇒ เคสจริงที่เจอ: jest ได้ `moduleNameMapper` ซ้ำ 2 บล็อก
#   (duplicate key = ts parse error) · tsconfig เสีย compilerOptions ที่เหลือ/วงเล็บหาย
#   ตัวใหม่แทนที่ "เฉพาะเนื้อในบล็อกเป้าหมาย" โดยไล่วงเล็บจริง (ข้าม string/comment)
#   ⇒ comment · key อื่น · การจัดรูป นอกบล็อก ไม่ถูกแตะเลย
#
# fail-closed: หาบล็อกเป้าหมายไม่เจอ = abort ไม่แตะไฟล์ (ยกเว้น paths ที่ insert ให้ได้
# ใต้ compilerOptions) — ยอมให้คนเติมเองดีกว่าเขียนทับพัง
set -euo pipefail

PACKAGE_NAME="${1:-}"
if [ -z "$PACKAGE_NAME" ]; then
  echo "Usage: update_alias_path.sh <package-name>" >&2
  exit 1
fi

lib_folder="./lib"
if [ ! -d "$lib_folder" ]; then
  echo "Error: lib folder not found at $lib_folder" >&2
  exit 1
fi

# sub-module = โฟลเดอร์ชั้นเดียวใต้ ./lib (feature-* · ui-* · ฯลฯ)
submodules=()
for folder in "$lib_folder"/*; do
  [ -d "$folder" ] && submodules+=("$(basename "$folder")")
done

patcher="$(mktemp -t update_alias_path.XXXXXX).mjs"
trap 'rm -f "$patcher"' EXIT

cat > "$patcher" << 'PATCHER_EOF'
import { readFileSync, writeFileSync, existsSync, copyFileSync } from 'node:fs';

const [pkg, ...subs] = process.argv.slice(2);

// ── brace matcher ที่ข้าม string + comment (กันวงเล็บใน '// {' หรือ "a{b" หลอก) ──
function findBlock(src, keyPattern) {
  const re = new RegExp(`^([ \\t]*)(${keyPattern})[ \\t]*:[ \\t]*\\{`, 'm');
  const m = re.exec(src);
  if (!m) return null;
  const open = m.index + m[0].length; // ตำแหน่งถัดจาก '{'
  let depth = 1;
  let i = open;
  let quote = null;
  let comment = null;
  while (i < src.length && depth > 0) {
    const c = src[i];
    const next = src[i + 1];
    if (comment === 'line') {
      if (c === '\n') comment = null;
    } else if (comment === 'block') {
      if (c === '*' && next === '/') { comment = null; i++; }
    } else if (quote) {
      if (c === '\\') i++;
      else if (c === quote) quote = null;
    } else if (c === '/' && next === '/') { comment = 'line'; i++; }
    else if (c === '/' && next === '*') { comment = 'block'; i++; }
    else if (c === '"' || c === "'" || c === '`') quote = c;
    else if (c === '{') depth++;
    else if (c === '}') depth--;
    i++;
  }
  if (depth !== 0) return null; // วงเล็บไม่สมดุล — ไม่แตะดีกว่า
  return { indent: m[1], open, close: i - 1 }; // close = index ของ '}' ที่ปิด
}

// ── v1.7.1: เก็บ entry ที่ "ไม่ใช่ของที่ tool นี้ดูแล" ไว้ ──────────────────────────
// ของเดิมแทนที่ทั้งบล็อก ⇒ alias `@` / `@root` ที่ **template ใส่มาเอง** หายทุกครั้งที่รัน
// (template ↔ tool ขัดกัน — owner เคาะ: template เป็นเจ้าของ ⇒ tool ต้องไม่ลบ)
// managed = ชื่อ package + sub-module เท่านั้น · ที่เหลือ = ของคนอื่น ห้ามแตะ
function foreignEntries(src, block, managed) {
  const out = [];
  for (const raw of src.slice(block.open, block.close).split('\n')) {
    const line = raw.trim();
    if (!line) continue;
    if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) continue;
    if (line.startsWith('...')) continue; // spread ของ base config — ตัวสร้างใส่เองอยู่แล้ว
    const m = line.match(/^['"]?\^?@([A-Za-z0-9._-]*)/);
    if (!m) continue;                          // อ่าน key ไม่ออก = ไม่เก็บ (กันสะสมขยะ)
    const key = m[1];
    if (managed.has(key)) continue;            // ของ tool เอง — เดี๋ยวสร้างใหม่
    if (/^(feature|ui)-/.test(key)) continue;  // sub-module ที่ไม่มีอยู่แล้ว (ลบ/เปลี่ยนชื่อ) — ต้องหายไป
    // ใส่ comma ที่ **ท้ายโค้ด** ไม่ใช่ท้ายบรรทัด (บรรทัดที่มี trailing comment จะได้ไม่เพี้ยน)
    const ci = line.indexOf('//');
    let code = ci >= 0 ? line.slice(0, ci).trimEnd() : line;
    const comment = ci >= 0 ? ' ' + line.slice(ci) : '';
    if (!code.endsWith(',')) code += ',';
    out.push(code + comment);
  }
  return out;
}

/** แทนที่เฉพาะเนื้อในบล็อก `key: { … }` — ของนอกบล็อกไม่ขยับสักตัว
 *  build(foreign) → array ของบรรทัดที่จะเขียนลงบล็อก (foreign = entry เดิมที่ต้องเก็บไว้) */
function replaceBlock(file, keyPattern, build, opts = {}) {
  if (!existsSync(file)) return 'skip';
  const src = readFileSync(file, 'utf8');
  const block = findBlock(src, keyPattern);
  const innerLines = build(block ? foreignEntries(src, block, opts.managed || new Set()) : []);
  const body = innerLines.map((l) => `  ${l}`).join('\n');

  if (block) {
    const inner = `\n${block.indent}${body.split('\n').join(`\n${block.indent}`)}\n${block.indent}`;
    copyFileSync(file, `${file}.bak`);
    writeFileSync(file, src.slice(0, block.open) + inner + src.slice(block.close));
    return 'patched';
  }

  // ไม่มีบล็อก: insert ได้เฉพาะเมื่อบอก anchor มา (เคส paths ใต้ compilerOptions)
  if (opts.anchor) {
    const anchor = findBlock(src, opts.anchor);
    if (anchor) {
      const inner = `\n${anchor.indent}  ${opts.key}: {\n${anchor.indent}  ${body}\n${anchor.indent}  },`;
      copyFileSync(file, `${file}.bak`);
      writeFileSync(file, src.slice(0, anchor.open) + inner + src.slice(anchor.open));
      return 'inserted';
    }
  }
  return 'missing';
}

function report(file, key, outcome) {
  if (outcome === 'skip') return;
  if (outcome === 'missing') {
    console.error(`✖ ${file}: หาบล็อก \`${key}\` ไม่เจอ (หรือวงเล็บไม่สมดุล) — ไม่แตะไฟล์`);
    console.error(`  เติมบล็อกว่างเองแล้วรันใหม่:  ${key}: {}`);
    process.exitCode = 1;
    return;
  }
  console.log(`✔ ${file}: ${key} ${outcome}`);
}

// ── สร้างเนื้อของแต่ละบล็อกจาก sub-module list ──
// managed = key ที่ tool นี้เป็นเจ้าของ (สร้างใหม่ทุกรอบ) · นอกเหนือจากนี้ = ของ template/repo → เก็บไว้
const managed = new Set([pkg, ...subs]);

const tsPaths = (foreign) => [
  ...foreign,
  `"@${pkg}/*": ["./lib/*"],`,
  ...subs.map((s) => `"@${s}/*": ["./lib/${s}/*"],`),
];
const jestMappers = (foreign) => [
  // ต้อง spread base ไว้ตัวแรกเสมอ ไม่งั้น react-pin/css mapper ของ base หาย → jest พัง
  '...(baseConfig.moduleNameMapper || {}),',
  ...foreign,
  `'^@${pkg}/(.*)$': '<rootDir>/lib/$1',`,
  ...subs.map((s) => `'^@${s}/(.*)$': '<rootDir>/lib/${s}/$1',`),
];
const viteAliases = (foreign) => [
  ...foreign,
  `'@${pkg}': resolve(__dirname, './lib'),`,
  ...subs.map((s) => `'@${s}': resolve(__dirname, './lib/${s}'),`),
];

for (const f of ['tsconfig.json', 'tsconfig.build.json']) {
  report(f, '"paths"', replaceBlock(f, '"paths"', tsPaths, { anchor: '"compilerOptions"', key: '"paths"', managed }));
}
report('jest.config.ts', 'moduleNameMapper', replaceBlock('jest.config.ts', 'moduleNameMapper', jestMappers, { managed }));
report('vite.config.ts', 'alias', replaceBlock('vite.config.ts', 'alias', viteAliases, { managed }));
PATCHER_EOF

# ไฟล์ไหน fail (บล็อกหาย) patcher จะรายงานแล้วคืน 1 — แต่ไฟล์ที่สำเร็จต้องได้จัดรูปด้วย
# จึงเก็บ exit code ไว้ก่อน แล้วค่อยคืนตอนท้าย (ไม่ให้ set -e ตัดจบกลางคัน)
patch_status=0
node "$patcher" "$PACKAGE_NAME" "${submodules[@]}" || patch_status=$?

# จัดรูปด้วย prettier ของ workspace (บล็อกที่เขียนไปเป็น valid syntax อยู่แล้ว — prettier แค่จัดสวย)
for f in tsconfig.json tsconfig.build.json jest.config.ts vite.config.ts; do
  [ -f "$f" ] && npx prettier --write "$f" > /dev/null
done

if [ "$patch_status" -ne 0 ]; then
  echo "✖ alias update ไม่ครบ — ดูไฟล์ที่รายงานด้านบน (ของที่สำเร็จถูกเขียน+จัดรูปแล้ว)" >&2
  exit "$patch_status"
fi

echo "Updated alias paths for @$PACKAGE_NAME (${#submodules[@]} sub-modules: ${submodules[*]})"
