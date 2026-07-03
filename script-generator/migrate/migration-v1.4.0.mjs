// migration-v1.4.0.mjs — Migration → v1.4.0 : dev-condition export strategy
// (lint/test/build ไม่ต้อง build local dependency ก่อน)
//
// ⚙️ ปกติรันผ่าน driver: `bash apply-migration.sh <ws>` (driver จัดลำดับ + bump template-version + เขียน log ให้)
//    รันตรงก็ได้: node migration-v1.4.0.mjs <WORKSPACE_ROOT | path-to-node-app>
//    รับได้ทั้ง git root (มี workspaces/node-app) และ path ของ node-app ตรง ๆ
//
// สิ่งที่ทำ:
// 1. nx.json: เอา ^build ออกจาก lint/test/build (คงไว้ที่ serve/release)
// 2. tsconfig base + tsconfig ของ apps: เพิ่ม customConditions ["development"]
// 3. jest.config.*: เพิ่ม testEnvironmentOptions.customExportConditions
// 4. ทุก lib ใน libs/** ที่มี exports: เพิ่ม "development" ชี้ source + sideEffects (backend:false / frontend:css-scss)
// 5. apps/**: override nx targets.build.dependsOn = ["^build"]
// 6. tsup config: minify false
import fs from 'node:fs';
import path from 'node:path';

// รับได้ทั้ง git root (มี workspaces/node-app) และ path ของ node-app โดยตรง (driver ส่ง git root มา)
let ROOT = process.argv[2];
if (ROOT && fs.existsSync(path.join(ROOT, 'workspaces', 'node-app', 'pnpm-workspace.yaml'))) {
  ROOT = path.join(ROOT, 'workspaces', 'node-app');
}
if (!ROOT || !fs.existsSync(path.join(ROOT, 'pnpm-workspace.yaml'))) {
  console.error('usage: node migration-v1.4.0.mjs <WORKSPACE_ROOT | path-to-node-app (มี pnpm-workspace.yaml)>');
  process.exit(1);
}
const P = (...p) => path.join(ROOT, ...p);
const log = (...a) => console.log('[migrate]', ...a);

// ---------- helpers ----------
function* walkPkgJson(dir) {
  if (!fs.existsSync(dir)) return;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.name === 'node_modules' || e.name === 'dist' || e.name.startsWith('.')) continue;
    const fp = path.join(dir, e.name);
    if (e.isDirectory()) yield* walkPkgJson(fp);
    else if (e.name === 'package.json') yield fp;
  }
}
const readJson = (f) => JSON.parse(fs.readFileSync(f, 'utf8'));
const writeJson = (f, o) => fs.writeFileSync(f, JSON.stringify(o, null, 2) + '\n');

// ---------- 1) nx.json ----------
{
  const f = P('nx.json');
  if (fs.existsSync(f)) {
    const nx = readJson(f);
    for (const t of ['lint', 'test', 'build']) {
      const d = nx.targetDefaults?.[t]?.dependsOn;
      if (d) {
        nx.targetDefaults[t].dependsOn = d.filter((x) => x !== '^build');
        if (!nx.targetDefaults[t].dependsOn.length) delete nx.targetDefaults[t].dependsOn;
      }
    }
    writeJson(f, nx);
    log('nx.json: removed ^build from lint/test/build');
  }
}

// ---------- 2) tsconfig (JSONC -> text patch) ----------
function patchTsconfig(f) {
  if (!fs.existsSync(f)) return;
  let txt = fs.readFileSync(f, 'utf8');
  if (/^\s*"customConditions"/m.test(txt)) return log('tsconfig already patched:', path.relative(ROOT, f));
  if (/\/\/\s*"customConditions"/.test(txt)) {
    txt = txt.replace(/\/\/\s*"customConditions":\s*\[\],?/, '"customConditions": ["development"],');
  } else {
    txt = txt.replace(/("compilerOptions"\s*:\s*\{)/, '$1\n    "customConditions": ["development"],');
  }
  fs.writeFileSync(f, txt);
  log('tsconfig patched:', path.relative(ROOT, f));
}
// เฉพาะ base ที่ตั้ง moduleResolution เอง (tsconfig-api-*.base.json extends tsconfig.base อยู่แล้ว)
for (const name of ['tsconfig.base.json', 'tsconfig.features.base.json']) patchTsconfig(P(name));
// tsconfig ของ apps (extends ภายนอก เช่น fastify-tsconfig จะไม่ inherit base)
for (const pkg of [...walkPkgJson(P('apps'))]) {
  const dir = path.dirname(pkg);
  for (const t of ['tsconfig.json', 'tsconfig-build.json']) {
    const f = path.join(dir, t);
    if (fs.existsSync(f) && fs.readFileSync(f, 'utf8').includes('"extends"')) patchTsconfig(f);
  }
}

// ---------- 3) jest configs ----------
for (const name of fs.readdirSync(ROOT).filter((n) => /^jest\.config\..*\.ts$/.test(n))) {
  const f = P(name);
  let txt = fs.readFileSync(f, 'utf8');
  if (txt.includes('customExportConditions')) { log('jest already patched:', name); continue; }
  const jsdom = /jsdom/.test(txt);
  const cond = jsdom ? "['development', '']" : "['development', 'node', 'node-addons']";
  const inject = `  testEnvironmentOptions: { customExportConditions: ${cond} },\n`;
  if (/testEnvironment:\s*'[^']+',\n/.test(txt)) txt = txt.replace(/(testEnvironment:\s*'[^']+',\n)/, `$1${inject}`);
  else txt = txt.replace(/(\.\.\.baseConfig,\n)/, `$1${inject}`);
  fs.writeFileSync(f, txt);
  log('jest patched:', name);
}

// ---------- 4) libs exports + sideEffects ----------
function devTarget(value, srcDir, frontend) {
  let v = value.replace(/^\.\/dist\//, `./${srcDir}/`);
  if (frontend) {
    const base = v.replace(/\.(js|cjs|mjs)$/, '');
    return [`${base}.tsx`, `${base}.ts`];
  }
  return v.replace(/\.(mjs|js|cjs)$/, '.ts');
}
for (const f of walkPkgJson(P('libs'))) {
  const pkg = readJson(f);
  if (!pkg.exports || typeof pkg.exports === 'string') continue;
  const dir = path.dirname(f);
  const srcDir = fs.existsSync(path.join(dir, 'src')) ? 'src' : fs.existsSync(path.join(dir, 'lib')) ? 'lib' : null;
  if (!srcDir) continue;
  const frontend = srcDir === 'lib';
  let changed = false;
  const out = {};
  for (const [key, val] of Object.entries(pkg.exports)) {
    if (val && typeof val === 'object' && !Array.isArray(val) && !val.development) {
      const base = val.import || val.require || val.default;
      out[key] = base ? { development: devTarget(base, srcDir, frontend), ...val } : val;
      changed = changed || !!base;
    } else out[key] = val;
  }
  if (changed || pkg.sideEffects === undefined) {
    pkg.exports = out;
    // sideEffects: frontend lib (lib/) อาจ import CSS/SCSS ซึ่งเป็น side-effect-only
    // -> ห้าม false (ไม่งั้น bundler tree-shake CSS ทิ้ง style หายตอน build)
    // backend lib (src/) ไม่มี CSS -> false ได้ (tree-shake เต็มที่)
    if (pkg.sideEffects === undefined) pkg.sideEffects = frontend ? ['**/*.css', '**/*.scss'] : false;
    writeJson(f, pkg);
    log('lib exports patched:', path.relative(ROOT, f));
  }
}

// ---------- 5) apps nx override ----------
for (const f of walkPkgJson(P('apps'))) {
  const pkg = readJson(f);
  pkg.nx = { ...(pkg.nx || {}), targets: { ...(pkg.nx?.targets || {}), build: { ...(pkg.nx?.targets?.build || {}), dependsOn: ['^build'] } } };
  writeJson(f, pkg);
  log('app nx.targets.build dependsOn ^build:', path.relative(ROOT, f));
}

// ---------- 6) tsup minify ----------
for (const f of [P('tsup.lib.config.ts'), ...[...walkPkgJson(P('libs'))].map((p) => path.join(path.dirname(p), 'tsup.config.ts'))]) {
  if (!fs.existsSync(f)) continue;
  const txt = fs.readFileSync(f, 'utf8');
  if (/minify:\s*true/.test(txt)) {
    fs.writeFileSync(f, txt.replace(/minify:\s*true/, 'minify: false'));
    log('tsup minify=false:', path.relative(ROOT, f));
  }
}

log('DONE — ตรวจ diff ด้วย git แล้วลอง: ลบ dist ทั้งหมด -> รัน lint/test ของ project ที่มี local dependency');
