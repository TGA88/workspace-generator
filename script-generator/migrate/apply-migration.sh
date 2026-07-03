#!/bin/bash
# apply-migration.sh — migration DRIVER (เหมือน liquibase): เช็ค version ปัจจุบันของ workspace
# แล้วรัน migration-v<semver> ที่ยัง "ค้าง" ตามลำดับ · อัป template-version + เขียน log ให้อัตโนมัติ
#
# ── ใช้ยังไง ───────────────────────────────────────────────────────────────────────
#   bash apply-migration.sh <WORKSPACE_ROOT> [options]
#     WORKSPACE_ROOT = git root ของ workspace (มี workspaces/node-app)
#   options:
#     --to <ver>     ปลายทาง · full semver (1.5.0 = หยุดเป๊ะ) หรือ minor (1.5 = patch ล่าสุดของ 1.5) · default = ล่าสุดสุด
#     --dry-run      แสดงแผน (จะรันอะไรตามลำดับ) โดยไม่รันจริง · ไม่แตะ version/log
#     --list         แสดง version ปัจจุบัน + migration ทั้งหมด (applied/pending)
#     --rerun <ver>  บังคับรัน migration version นั้นซ้ำ (แม้ applied แล้ว) · ไม่ downgrade version
#
# ── หลักการ ─────────────────────────────────────────────────────────────────────
# · driver = ลำดับ + version marker + log · migration-v* = "งาน" (จะเรียก lib/sync-infra หรือไม่ก็ได้)
# · รันเฉพาะ version ที่ > current → **ไม่มีวัน downgrade** · migration idempotent → รันซ้ำ/รันจากต้นปลอดภัย
# · migration พัง = ไม่ bump version + หยุด → แก้แล้ว "รัน apply-migration ซ้ำ" = retry อัตโนมัติ (ยังค้างอยู่)
# · log: workspaces/node-app/workspace-history/migration-history/ (index.log + <seq>-v<ver>-<ts>.log ต่อ run)
set -e

# ── parse args ──
WS_ROOT=""; TO=""; DRY=0; LIST=0; RERUN=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)      TO="$2"; shift;;
    --dry-run) DRY=1;;
    --list)    LIST=1;;
    --rerun)   RERUN="$2"; shift;;
    -h|--help) sed -n '2,18p' "$0"; exit 0;;
    -*)        echo "Error: unknown flag $1"; exit 1;;
    *)         [ -z "$WS_ROOT" ] && WS_ROOT="$1" || { echo "Error: extra arg $1"; exit 1; };;
  esac
  shift
done
[ -z "$WS_ROOT" ] && { read -rp "workspace root (git root ที่มี workspaces/node-app): " WS_ROOT; }
[ -z "$WS_ROOT" ] && { echo "Error: WORKSPACE_ROOT is required"; exit 1; }
WS_ROOT="$(cd "$WS_ROOT" && pwd)"
WS_NAME="$(basename "$WS_ROOT")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GEN="$(cd "$SCRIPT_DIR/../.." && pwd)"
NA="$WS_ROOT/workspaces/node-app"
VERFILE="$NA/template-version"
HIST="$NA/workspace-history/migration-history"
INDEX="$HIST/index.log"

# ── precondition ──
[ -f "$NA/pnpm-workspace.yaml" ] || { echo "Error: $NA/pnpm-workspace.yaml ไม่พบ — ไม่ใช่ workspace ที่ถูกต้อง"; exit 1; }

# ── helpers ──
ver_le() { [ "$1" = "$2" ] || [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ]; }  # A <= B
ver_gt() { ! ver_le "$1" "$2"; }                                                                    # A > B
GEN_SHA="$(git -C "$GEN" rev-parse --short HEAD 2>/dev/null || echo '?')"
GEN_BRANCH="$(git -C "$GEN" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"

CUR="0.0.0"; [ -f "$VERFILE" ] && CUR="$(tr -d '[:space:]' < "$VERFILE" || true)"; [ -z "$CUR" ] && CUR="0.0.0"

# list_migrations → "<ver>\t<path>" เรียง semver จากน้อยไปมาก
list_migrations() {
  local f b ver
  for f in "$SCRIPT_DIR"/migration-v*.sh "$SCRIPT_DIR"/migration-v*.mjs; do
    [ -e "$f" ] || continue
    b="$(basename "$f")"; ver="${b#migration-v}"; ver="${ver%.sh}"; ver="${ver%.mjs}"
    printf '%s\t%s\n' "$ver" "$f"
  done | sort -V
}

# run_one <ver> <path> <from> → รัน 1 migration, log, bump version (ถ้าสำเร็จ+สูงกว่า) · return 0/1
run_one() {
  local ver="$1" path="$2" from="$3"
  local ts_iso ts_file seq detail base rc status end_iso n
  ts_iso="$(date +%FT%T%z)"; ts_file="$(printf '%s' "$ts_iso" | tr -d ':-')"
  base="$(basename "$path")"
  mkdir -p "$HIST"
  n="$(grep -c '^[0-9]' "$INDEX" 2>/dev/null || true)"; [ -z "$n" ] && n=0
  seq="$(printf '%04d' "$((n+1))")"
  detail="$HIST/${seq}-v${ver}-${ts_file}.log"
  echo ">> migration → v$ver   ($from -> $ver)   [$base]"
  {
    echo "==== migration run #${seq} ===="
    echo "migration : $base   ($from -> $ver)"
    echo "started   : $ts_iso"
    echo "generator : $GEN_SHA  (branch $GEN_BRANCH)"
    echo "workspace : $WS_NAME"
    echo "command   : $([ "${base##*.}" = mjs ] && echo node || echo bash) $base $WS_ROOT"
    echo "------------------------------------------------------------"
  } > "$detail"
  set +e
  case "$base" in
    *.mjs) node "$path" "$WS_ROOT" 2>&1 | tee -a "$detail" ;;
    *)     bash "$path" "$WS_ROOT" 2>&1 | tee -a "$detail" ;;
  esac
  rc=${PIPESTATUS[0]}
  set -e
  end_iso="$(date +%FT%T%z)"
  [ "$rc" -eq 0 ] && status="OK" || status="FAIL"
  {
    echo "------------------------------------------------------------"
    echo "finished  : $end_iso"
    echo "status    : $status  (exit $rc)"
  } >> "$detail"
  [ -f "$INDEX" ] || printf '# seq | timestamp | from -> to | migration | status | gen | detail\n' > "$INDEX"
  printf '%s | %s | %s -> %s | %s | %-4s | %s | %s\n' \
    "$seq" "$ts_iso" "$from" "$ver" "$base" "$status" "$GEN_SHA" "$(basename "$detail")" >> "$INDEX"
  echo "   [$status] log: workspace-history/migration-history/$(basename "$detail")"
  if [ "$status" = "OK" ]; then
    if ver_gt "$ver" "$CUR"; then printf '%s\n' "$ver" > "$VERFILE"; CUR="$ver"; fi
    return 0
  fi
  return 1
}

# ── --list ──
if [ "$LIST" = 1 ]; then
  echo "workspace : $WS_NAME"
  echo "current   : $CUR"
  echo "generator : $GEN_SHA (branch $GEN_BRANCH)"
  echo "migrations:"
  while IFS="$(printf '\t')" read -r ver path; do
    [ -z "$ver" ] && continue
    if ver_gt "$ver" "$CUR"; then mark="pending"; else mark="applied"; fi
    printf '  v%-8s %-24s [%s]\n' "$ver" "$(basename "$path")" "$mark"
  done <<EOF
$(list_migrations)
EOF
  exit 0
fi

# ── --rerun <ver> ──
if [ -n "$RERUN" ]; then
  RPATH="$(list_migrations | awk -F"$(printf '\t')" -v v="$RERUN" '$1==v{print $2}')"
  [ -z "$RPATH" ] && { echo "Error: ไม่มี migration-v$RERUN"; exit 1; }
  echo "=== [apply-migration] RERUN v$RERUN บน $WS_NAME (current=$CUR) ==="
  if [ "$DRY" = 1 ]; then echo "  (DRY-RUN) จะ rerun v$RERUN [$(basename "$RPATH")]"; exit 0; fi
  run_one "$RERUN" "$RPATH" "rerun@$CUR" || { echo "!! rerun v$RERUN ล้มเหลว — ดู log" >&2; exit 1; }
  echo "=== done (rerun · template-version = $CUR) ==="
  exit 0
fi

# ── determine target ──
HIGHEST="$(list_migrations | cut -f1 | tail -n1)"
[ -z "$HIGHEST" ] && { echo "Error: ไม่พบ migration-v*.{sh,mjs} ใน $SCRIPT_DIR"; exit 1; }
if [ -z "$TO" ]; then
  TARGET="$HIGHEST"
else
  DOTS="$(printf '%s' "$TO" | tr -cd '.' | awk '{print length}')"
  if [ "$DOTS" = 1 ]; then
    TARGET="$(list_migrations | cut -f1 | grep -E "^$(printf '%s' "$TO" | sed 's/\./\\./g')\." | sort -V | tail -n1 || true)"
    [ -z "$TARGET" ] && { echo "Error: ไม่มี migration สำหรับ minor $TO"; exit 1; }
  elif [ "$DOTS" = 2 ]; then
    TARGET="$TO"
  else
    echo "Error: --to ต้องเป็น <minor> (เช่น 1.5) หรือ <full> (เช่น 1.5.0)"; exit 1
  fi
fi

# ── compute pending ──
PENDING="$(list_migrations | while IFS="$(printf '\t')" read -r ver path; do
  [ -z "$ver" ] && continue
  if ver_gt "$ver" "$CUR" && ver_le "$ver" "$TARGET"; then printf '%s\t%s\n' "$ver" "$path"; fi
done)"

echo "=== [apply-migration] $WS_NAME : current=$CUR → target=$TARGET ==="
if [ -z "$PENDING" ]; then echo "  ✓ ไม่มี migration ค้าง (ทันสมัยแล้ว)"; exit 0; fi
echo "  แผน (pending · ตามลำดับ):"
printf '%s\n' "$PENDING" | while IFS="$(printf '\t')" read -r ver path; do
  [ -z "$ver" ] && continue; echo "    → v$ver   [$(basename "$path")]"
done
if [ "$DRY" = 1 ]; then echo "  (DRY-RUN — ไม่รันจริง · ไม่เขียน log/version)"; exit 0; fi

# ── run pending ตามลำดับ (here-string = current shell → FROM/CUR อัปได้ · fail แล้วหยุดจริง) ──
FROM="$CUR"
while IFS="$(printf '\t')" read -r ver path; do
  [ -z "$ver" ] && continue
  run_one "$ver" "$path" "$FROM" || {
    echo "!! หยุดที่ v$ver — แก้ต้นเหตุ (ดู log) แล้วรัน 'apply-migration.sh $WS_ROOT' ซ้ำได้ (retry อัตโนมัติ)" >&2
    exit 1
  }
  FROM="$ver"
done <<EOF
$PENDING
EOF

echo "=== ✓ done · template-version = $CUR · log: workspaces/node-app/workspace-history/migration-history/index.log ==="
