#!/bin/bash
# migration-v1.7.1.sh — Migration → v1.7.1 : storybook host scope ตาม base + OOM knob ใน verify Dockerfile
#
# ── ทำอะไร ─────────────────────────────────────────────────────────────────────
# 1) sync tool 2 ตัวใน `tools/` (generator-owned) ให้ตรง template:
#      · update_storybookhost_alias.sh — เลิกสแกน `libs/` ทั้งก้อน → scope ตาม `stories` ของ host เอง
#      · update_alias_path.sh          — เลิกลบ alias ที่ไม่ใช่ sub-module (`@` · `@root` ของ template)
# 2) **patch** `Dockerfile.verify-*` ที่มีอยู่ (ไม่ copy ทับ) — เติม `--workspace-concurrency=1`
#    ให้ step `pnpm … run <script>` ที่ยังไม่มี  (กัน OOM/exit 137 ในคอนเทนเนอร์ RAM จำกัด)
# 3) รายงาน storybook host ที่ `stories` ยังเป็น `libs/**` = ยังครอบทุก base (false signal)
#
# ── ทำไม "patch" ไม่ใช่ `lib/sync-infra.sh` ────────────────────────────────────
# `Dockerfile.verify-backend` เป็น generator-owned ⇒ sync-infra **copy ทับทั้งไฟล์**
# แต่ adopter มี deviation จริงที่ template ยังไม่มี (auth-portal แยก fe/be เป็น
# `Dockerfile.verify-frontend` + ปรับ --filter ให้ตรง libs ของตัวเอง) — copy ทับ = ลบงานเขา
# ⇒ ตัวนี้แก้แบบ **targeted + idempotent**: แตะเฉพาะ flag ที่ต้องเติม บรรทัดอื่นไม่ขยับ
# (fe/be split เข้า template = คุยแยก · ยังไม่มี frontend arm มาตรฐานใน template — ดู CHANGELOG)
#
# ⚠️ ยังไม่ปิดหนี้: รอบหน้าถ้าใครเรียก `sync-infra` ตรง ๆ ก็ยังทับ `Dockerfile.verify-backend` อยู่ดี
#
# contract: ห้ามเขียน template-version / log เอง (driver ทำให้) · idempotent (รันซ้ำได้)
set -euo pipefail

WORKSPACE_DIR="${1:?usage: migration-v1.7.1.sh <workspace-dir>}"
[ -d "$WORKSPACE_DIR" ] || { echo "ERROR: ไม่พบ workspace dir: $WORKSPACE_DIR"; exit 1; }

WS_ROOT="$(cd "$WORKSPACE_DIR" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"                  # .../script-generator/migrate
GEN="$(cd "$SCRIPT_DIR/../.." && pwd)"                       # generator root
TPL="$GEN/script-generator/template/workspace"
NA="$WS_ROOT/workspaces/node-app"

[ -f "$NA/pnpm-workspace.yaml" ] || { echo "ERROR: $NA/pnpm-workspace.yaml ไม่พบ — ไม่ใช่ workspace ที่ถูกต้อง"; exit 1; }

echo "migration v1.7.1: storybook scope + verify OOM knob"

# ── 1) sync tool ที่เปลี่ยน (generator-owned · ย้อนได้ด้วย git checkout) ──
echo "  [1/3] sync tools/"
for t in update_storybookhost_alias.sh update_alias_path.sh; do
  src="$TPL/tools/$t"; dest="$NA/tools/$t"
  if [ ! -f "$src" ]; then echo "    ? template ไม่มี $t (ข้าม)"; continue; fi
  if [ ! -f "$dest" ]; then
    mkdir -p "$NA/tools"; cp "$src" "$dest"; echo "    + added     tools/$t"
  elif ! cmp -s "$src" "$dest"; then
    cp "$src" "$dest"; echo "    ~ updated   tools/$t"
  else
    echo "    = unchanged tools/$t"
  fi
done

# ── 2) patch verify Dockerfile ที่มีอยู่ (ไม่ copy ทับ) ──
# เติม --workspace-concurrency=1 เฉพาะบรรทัด `RUN pnpm … run <script>` ที่ใช้ -r/--filter
# และยังไม่มี flag นี้ · บรรทัด `pnpm install` ไม่เข้าเงื่อนไข (ไม่มี ` run `)
echo "  [2/3] patch Dockerfile.verify-* (targeted · ไม่ทับทั้งไฟล์)"
patched_any=0
shopt -s nullglob
for df in "$NA"/Dockerfile.verify*; do
  # เอาเฉพาะไฟล์จริง — ไม่แตะ .bak/.orig/~ ที่คนเก็บไว้ข้าง ๆ (glob เดิมจับหมด)
  [[ "$(basename "$df")" =~ ^Dockerfile\.verify(-[A-Za-z0-9_-]+)?$ ]] || continue
  before="$(md5 -q "$df" 2>/dev/null || md5sum "$df" | cut -d' ' -f1)"
  perl -pi -e '
    if (/^RUN\s+pnpm\b/ && /\srun\s/ && !/--workspace-concurrency/ && /\s(-r|--filter)\s/) {
      if (/\s--if-present\s+run\s/) { s/\s--if-present(\s+run\s)/ --workspace-concurrency=1 --if-present$1/ }
      else                          { s/(\s)run(\s)/$1--workspace-concurrency=1 run$2/ }
    }
  ' "$df"
  after="$(md5 -q "$df" 2>/dev/null || md5sum "$df" | cut -d' ' -f1)"
  if [ "$before" != "$after" ]; then
    echo "    ~ patched   node-app/$(basename "$df")"; patched_any=1
  else
    echo "    = ok        node-app/$(basename "$df")  (มี --workspace-concurrency=1 ครบแล้ว หรือไม่มี step ที่ต้องเติม)"
  fi
done
[ "$patched_any" = 0 ] && echo "    (ไม่มีอะไรต้องแก้)"

# ── 3) รายงาน storybook host ที่ยังครอบทุก base ──
echo "  [3/3] ตรวจ scope ของ storybook host"
found_host=0; wide=0
for main in "$NA"/storybook-host/*/.storybook/main.ts; do
  found_host=1
  host="$(basename "$(dirname "$(dirname "$main")")")"
  if grep -qE "libs/\*\*/" "$main"; then
    echo "    ! $host: stories ยังเป็น 'libs/**' = ครอบทุก base"
    echo "        → แก้เป็น 'libs/<lib ของ base นี้>/**/…' ใน $main"
    wide=1
  else
    echo "    ✓ $host: stories scope แล้ว"
  fi
done
shopt -u nullglob
[ "$found_host" = 0 ] && echo "    (ยังไม่มี storybook-host)"

echo ""
echo "  ⇒ ต้องทำต่อด้วยมือ: รัน 'pnpm update:storybook_alias' ที่ storybook host แต่ละตัว"
echo "    (tool ตัวใหม่จะล้าง alias ข้าม base ที่ถูกเขียนไว้ก่อนหน้าออกให้ — migration ไม่รันเองเพราะต้องใช้ npx/prettier ของ workspace)"
[ "$wide" = 1 ] && echo "    ⚠️ host ที่ยังเป็น 'libs/**' ให้แก้ stories ก่อน ไม่งั้น alias ก็ยังกว้างเท่าเดิม (alias ตาม stories)"
exit 0
