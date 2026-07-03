#!/bin/bash
# lib/sync-infra.sh — UTILITY (ไม่ใช่ migration rung): re-sync generator-OWNED generic infra
# ไฟล์จาก template → workspace โดย **เขียนทับของเก่า** (force copy-if-different)
#
# ── ทำไมต้องมี ─────────────────────────────────────────────────────────────────
# create-workspace.sh cp ไฟล์เหล่านี้แบบ guard `[ -f ] ||` → คัดลอกเฉพาะตอน "ยังไม่มี" → พอ template
# อัปเดตทีหลัง (แก้บั๊ก verify Dockerfile, เพิ่ม gen-*.sh ใหม่ใน tools/) ไฟล์ใหม่ **ไม่ถึง** workspace เดิม → drift เงียบ ๆ
# ตัวนี้ = force-sync เฉพาะไฟล์ที่ generator เป็นเจ้าของ (tokenless · workspace ไม่แก้รายตัว) ให้ตรง template
#
# ── เป็น utility ล้วน ──────────────────────────────────────────────────────────────
# · **ไม่ยุ่ง template-version · ไม่เขียน log · ไม่รู้เรื่องลำดับ** — copy ไฟล์อย่างเดียว
# · migration rung ไหน "อยากได้" generic infra ก็ `bash lib/sync-infra.sh <ws>` เอง (เช่น migration-v1.5.0, migration-v1.5.1)
# · version marker + log = หน้าที่ของ apply-migration.sh (driver) ที่รัน rung นั้น
#
# ── manifest (เขียนทับได้ = generator-owned "read-only tooling/convention") ───────
#   node-app : .dockerignore · Dockerfile.verify-backend · Dockerfile.verify-nx-backend · tools/ (recursive)
#   git-root : .gitattributes · .editorconfig · WORKSPACE.md (operational cheat sheet — generator ดูแล 100%)
# EXCLUDE (workspace แก้รายตัว หรือมี token → ห้าม cp ทับ):
#   README.md (ของโปรเจกต์ — seed ครั้งเดียวตอน create) · .gitignore (สะสม entry เอง) · tsup.lib.config.ts (ปรับ build) · nx.json · tsconfig.base.json (paths) ·
#   pnpm-workspace.yaml · package.json (scripts) · Makefile (__WS__/__SERVICE__)
#   → Makefile + package.json เป็นงานของ new-infrastructure.sh + `npm pkg set` (มี token / ต้อง merge ไม่ใช่ cp)
#
# ── usage ───────────────────────────────────────────────────────────────────────
#   bash lib/sync-infra.sh <WORKSPACE_ROOT> [--dry-run] [--quiet] [--system <dir>]
#     WORKSPACE_ROOT = git root ของ workspace (มี workspaces/node-app)
#     --dry-run      = แสดงว่าจะเปลี่ยนอะไร โดยไม่เขียนจริง
#     --quiet        = พิมพ์เฉพาะ +added / ~updated (ข้าม =unchanged) — ใช้ตอนถูกเรียกจาก migration
#     --system <dir> = system dir ใต้ workspaces/ (default: node-app)
# safe: workspace = git repo → ย้อนได้ด้วย `git checkout -- <file>` · ไม่เคยลบไฟล์ (orphan = เตือนเฉย ๆ)
set -e

# ── parse args ──
WS_ROOT=""; DRY=0; QUIET=0; SYSTEM="node-app"
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1;;
    --quiet)   QUIET=1;;
    --system)  SYSTEM="$2"; shift;;
    -h|--help) sed -n '2,30p' "$0"; exit 0;;
    -*)        echo "Error: unknown flag $1"; exit 1;;
    *)         [ -z "$WS_ROOT" ] && WS_ROOT="$1" || { echo "Error: extra arg $1"; exit 1; };;
  esac
  shift
done
[ -z "$WS_ROOT" ] && { read -rp "workspace root (git root ที่มี workspaces/$SYSTEM): " WS_ROOT; }
[ -z "$WS_ROOT" ] && { echo "Error: WORKSPACE_ROOT is required"; exit 1; }
WS_ROOT="$(cd "$WS_ROOT" && pwd)"
WS_NAME="$(basename "$WS_ROOT")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"       # .../script-generator/migrate/lib
GEN="$(cd "$SCRIPT_DIR/../../.." && pwd)"          # lib → migrate → script-generator → generator root
TPL="$GEN/script-generator/template/workspace"
NA="$WS_ROOT/workspaces/$SYSTEM"

# ── precondition ──
[ -d "$TPL" ] || { echo "Error: template ไม่พบที่ $TPL"; exit 1; }
[ -f "$NA/pnpm-workspace.yaml" ] || { echo "Error: $NA/pnpm-workspace.yaml ไม่พบ — ไม่ใช่ workspace ที่ถูกต้อง (system=$SYSTEM)"; exit 1; }

echo "=== [sync-infra] $WS_NAME (system=$SYSTEM)$([ "$DRY" = 1 ] && echo '  [DRY-RUN]') ==="

# ── manifest (src rel : dest rel) ──
# NODE-APP-level: src = ใต้ $TPL/ , dest = ใต้ $NA/
NA_FILES="\
.dockerignore:.dockerignore
Dockerfile.verify-backend:Dockerfile.verify-backend
Dockerfile.verify-nx-backend:Dockerfile.verify-nx-backend"
# NODE-APP-level dirs (recursive · file-by-file)
NA_DIRS="tools"
# ROOT-level: src = ใต้ $TPL/root/ , dest = ใต้ $WS_ROOT/
ROOT_FILES="\
.gitattributes:.gitattributes
.editorconfig:.editorconfig
WORKSPACE.md:WORKSPACE.md"

ADDED=0; UPDATED=0; UNCHANGED=0; MISSING=0
do_copy() { [ "$DRY" = 1 ] && return 0; mkdir -p "$(dirname "$2")"; cp "$1" "$2"; }
sync_file() { # $1=src  $2=dest  $3=display
  local src="$1" dest="$2" name="$3"
  if [ ! -f "$src" ]; then echo "  ? template missing: $name (skip)"; MISSING=$((MISSING+1)); return; fi
  if [ ! -f "$dest" ]; then
    do_copy "$src" "$dest"; echo "  + added     $name"; ADDED=$((ADDED+1))
  elif ! cmp -s "$src" "$dest"; then
    do_copy "$src" "$dest"; echo "  ~ updated   $name"; UPDATED=$((UPDATED+1))
  else
    [ "$QUIET" = 1 ] || echo "  = unchanged $name"; UNCHANGED=$((UNCHANGED+1))
  fi
}

# ── node-app single files ──
while IFS=: read -r s d; do
  [ -z "$s" ] && continue
  sync_file "$TPL/$s" "$NA/$d" "$SYSTEM/$d"
done <<< "$NA_FILES"

# ── node-app dirs (recursive) — sync ทุกไฟล์ใน template · เตือน orphan (ไม่ลบ) ──
for dir in $NA_DIRS; do
  SRC_D="$TPL/$dir"; DEST_D="$NA/$dir"
  [ -d "$SRC_D" ] || { echo "  ? template dir missing: $dir (skip)"; continue; }
  while IFS= read -r sf; do
    rel="${sf#"$SRC_D"/}"
    sync_file "$sf" "$DEST_D/$rel" "$SYSTEM/$dir/$rel"
  done < <(find "$SRC_D" -type f | sort)
  if [ -d "$DEST_D" ]; then
    while IFS= read -r df; do
      rel="${df#"$DEST_D"/}"
      [ -f "$SRC_D/$rel" ] || echo "  ! orphan (ไม่มีใน template, เก็บไว้): $SYSTEM/$dir/$rel"
    done < <(find "$DEST_D" -type f | sort)
  fi
done

# ── root-level convention files ──
while IFS=: read -r s d; do
  [ -z "$s" ] && continue
  sync_file "$TPL/root/$s" "$WS_ROOT/$d" "$d"
done <<< "$ROOT_FILES"

# NOTE: ไม่แตะ template-version ที่นี่ (utility ล้วน) — version marker เป็นหน้าที่ของ apply-migration.sh (driver)

echo "=== [sync-infra] done: +$ADDED added · ~$UPDATED updated · =$UNCHANGED unchanged$([ "$MISSING" != 0 ] && echo " · ?$MISSING template-missing")$([ "$DRY" = 1 ] && echo '  (DRY-RUN — ไม่เขียนจริง)') ==="
[ "$DRY" = 1 ] && [ $((ADDED+UPDATED)) -gt 0 ] && echo "  ⇒ รันจริง: bash $(basename "$0") $WS_ROOT   (ย้อนได้: git checkout -- <file>)"
exit 0
