#!/bin/bash
# migration-v1.5.2.sh — Migration → v1.5.2 : ship WORKSPACE.md (operational cheat sheet + Developer Handbook link)
# = force-sync generator-owned files ผ่าน lib/sync-infra (WORKSPACE.md เข้า manifest แล้ว) · **ไม่แตะ README.md ของโปรเจกต์**
#
# ⚙️ ปกติรันผ่าน driver: `bash apply-migration.sh <ws>` (driver จัดลำดับ + bump template-version + เขียน log ให้)
#    รันตรงก็ได้ (ไม่ bump version/ไม่ log): bash migration-v1.5.2.sh <WORKSPACE_ROOT>
#   WORKSPACE_ROOT = git root of the target workspace (มี workspaces/node-app)
set -e

WS_ROOT=$1
if [ -z "$WS_ROOT" ]; then read -rp "workspace root (git root ที่มี workspaces/node-app): " WS_ROOT; fi
[ -z "$WS_ROOT" ] && { echo "Error: WORKSPACE_ROOT is required"; exit 1; }
WS_ROOT="$(cd "$WS_ROOT" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== [migration-v1.5.2] sync generic infra (+ WORKSPACE.md cheat sheet) ==="
# WORKSPACE.md = generator-owned → เข้า sync-infra manifest → force-sync ทุก workspace (ไม่ชน README ของโปรเจกต์)
bash "$SCRIPT_DIR/lib/sync-infra.sh" "$WS_ROOT" | sed 's/^/  /'

# NOTE: ไม่ bump template-version ที่นี่ — driver เขียน = 1.5.2 + log ให้หลัง rung นี้สำเร็จ
echo "=== [migration-v1.5.2] done ==="
