#!/bin/bash
# migration-v1.6.0.sh — Migration → v1.6.0 : frontend loop alignment + packages/ taxonomy
#
# ทำ 2 ส่วน (ต่างจาก 1.5.1/1.5.2 ที่เรียก sync-infra อย่างเดียว):
#   (1) force-sync generator-owned files ผ่าน lib/sync-infra → tools/ ได้ของใหม่
#       (update_alias_path.sh ที่เขียนใหม่ · generate-exports-web.sh · gen_front_skelton.sh โครง pages/logic)
#   (2) **patch ไฟล์ workspace-owned ที่ sync-infra จงใจไม่แตะ** — `pnpm-workspace.yaml` + root `package.json`
#       เพราะ packages/ taxonomy อยู่ในสองไฟล์นี้พอดี ถ้าไม่ทำ = upgrade แล้ว packages/ ยังใช้ไม่ได้จริง
#       (pnpm ไม่รู้จัก workspace · root globs ของ lint/test/build ไม่จับ)
#
# idempotent: ทุกขั้นมี guard — รันซ้ำไม่เพิ่มซ้ำ · workspace ที่ทำเองไปแล้ว (เช่น auth-portal ตอน R3) ข้ามให้
#
# ⚙️ ปกติรันผ่าน driver: `bash apply-migration.sh <ws>` (driver จัดลำดับ + bump template-version + เขียน log ให้)
#    รันตรงก็ได้ (ไม่ bump version/ไม่ log): bash migration-v1.6.0.sh <WORKSPACE_ROOT>
set -e

WS_ROOT=$1
if [ -z "$WS_ROOT" ]; then read -rp "workspace root (git root ที่มี workspaces/node-app): " WS_ROOT; fi
[ -z "$WS_ROOT" ] && { echo "Error: WORKSPACE_ROOT is required"; exit 1; }
WS_ROOT="$(cd "$WS_ROOT" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NA="$WS_ROOT/workspaces/node-app"

echo "=== [migration-v1.6.0] (1/2) sync generic infra (tools/ + verify Dockerfiles + conventions) ==="
bash "$SCRIPT_DIR/lib/sync-infra.sh" "$WS_ROOT" | sed 's/^/  /'

echo "=== [migration-v1.6.0] (2/2) packages/ taxonomy (workspace-owned files) ==="

# ── 2a. pnpm-workspace.yaml — เพิ่ม 'packages/**' ────────────────────────────────
PW="$NA/pnpm-workspace.yaml"
if [ ! -f "$PW" ]; then
  echo "  ⚠ ข้าม pnpm-workspace.yaml (ไม่พบที่ $PW)"
elif grep -qE "^[[:space:]]*-[[:space:]]*'?packages/\*\*'?" "$PW"; then
  echo "  ✔ pnpm-workspace.yaml: มี packages/** อยู่แล้ว — ข้าม"
else
  # แทรกหลังบรรทัด libs/** (คงลำดับให้ตรง template) พร้อมคอมเมนต์อธิบายเกณฑ์
  node - "$PW" << 'NODE_EOF'
const { readFileSync, writeFileSync, copyFileSync } = require('node:fs');
const file = process.argv[2];
const src = readFileSync(file, 'utf8');
const lines = src.split('\n');
const i = lines.findIndex((l) => /^\s*-\s*'?libs\/\*\*'?/.test(l));
if (i < 0) {
  console.error("  ✖ pnpm-workspace.yaml: หาบรรทัด libs/** ไม่เจอ — เพิ่ม \"- 'packages/**'\" เองแล้วรันใหม่");
  process.exit(1);
}
const indent = (lines[i].match(/^(\s*)/) || ['', ''])[1];
lines.splice(i + 1, 0,
  `${indent}# cross-repo publishable packages (public scope) — split by environment: frontend/ | backend/`,
  `${indent}# criterion: publishConfig.access === 'public' -> here ; 'restricted' -> libs/`,
  `${indent}- 'packages/**'`);
copyFileSync(file, `${file}.bak`);
writeFileSync(file, lines.join('\n'));
console.log('  ✔ pnpm-workspace.yaml: เพิ่ม packages/** แล้ว');
NODE_EOF
fi

# ── 2b. root package.json — 6 globs (lint/test/build × frontend-libs/backend-libs) ──
PKG="$NA/package.json"
if [ ! -f "$PKG" ]; then
  echo "  ⚠ ข้าม package.json (ไม่พบที่ $PKG)"
else
  node - "$PKG" << 'NODE_EOF'
const { readFileSync, writeFileSync, copyFileSync } = require('node:fs');
const file = process.argv[2];
const pkg = JSON.parse(readFileSync(file, 'utf8'));
const scripts = pkg.scripts || {};
// frontend arm ได้ packages/frontend/** · backend arm ได้ packages/backend/**
// (path glob — ชื่อ package ของ packages/ เป็นสาธารณะ ตั้งชื่อให้ glob จับไม่ได้)
const add = { 'frontend-libs': 'packages/frontend/**', 'backend-libs': 'packages/backend/**' };
let changed = 0;
for (const target of ['lint', 'test', 'build']) {
  for (const [arm, glob] of Object.entries(add)) {
    const key = `${target}:${arm}`;
    const val = scripts[key];
    if (typeof val !== 'string') continue;          // arm นี้ไม่มีในบาง workspace — ข้าม
    if (val.includes(glob)) continue;                // ทำไปแล้ว — idempotent
    if (!val.includes('--projects=')) continue;      // รูปไม่ตรงที่คาด — ไม่เดา
    // เติมท้ายรายการ --projects= (ก่อน --exclude ถ้ามี)
    scripts[key] = val.replace(/(--projects=)([^\s]+)/, (_m, p, list) => `${p}${list},${glob}`);
    changed++;
  }
}
if (changed === 0) {
  console.log('  ✔ package.json: globs มี packages/ อยู่แล้ว (หรือไม่มี arm ให้เติม) — ข้าม');
} else {
  pkg.scripts = scripts;
  copyFileSync(file, `${file}.bak`);
  writeFileSync(file, `${JSON.stringify(pkg, null, 2)}\n`);
  console.log(`  ✔ package.json: เติม packages/ glob ${changed} script`);
}
NODE_EOF
fi

cat << 'NOTE_EOF'

  ℹ️  หมายเหตุขอบเขต (อ่านก่อนงง):
     • ที่ migration ทำให้ = tooling/infra ของ workspace (tools/ · verify Dockerfiles · workspace globs)
     • โครง **project template** ที่เปลี่ยนใน 1.6.0 (feature-*/pages+logic · storybook-host test-runner ·
       web-config) มีผลกับ **project ที่ generate ใหม่เท่านั้น** — ของเดิมไม่ถูกย้อนโครงให้ (โดยตั้งใจ)
     • frontend lib เดิมที่อยากได้โครงใหม่ → ย้ายมือตาม handbook `frontend-structure §3`
     • หลัง migration: `pnpm install` (workspace glob เปลี่ยน) แล้วรัน lint/test ของ workspace ตามปกติ
NOTE_EOF

# NOTE: ไม่ bump template-version ที่นี่ — driver เขียน = 1.6.0 + log ให้หลัง rung นี้สำเร็จ
echo "=== [migration-v1.6.0] done ==="
