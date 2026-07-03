#!/bin/bash
# migration-v1.5.1.sh — Migration → v1.5.1 : re-sync generic infra (tokenless generator-owned files)
# = ไม่มีการเปลี่ยนโครงสร้าง · แค่ดึง generic infra ล่าสุดจาก template (verify Dockerfiles + tools/ + conventions + .dockerignore)
#
# ⚙️ ปกติรันผ่าน driver: `bash apply-migration.sh <ws>` (driver จัดลำดับ + bump template-version + เขียน log ให้)
#    รันตรงก็ได้ (ไม่ bump version/ไม่ log): bash migration-v1.5.1.sh <WORKSPACE_ROOT>
#   WORKSPACE_ROOT = git root of the target workspace (มี workspaces/node-app)
set -e

WS_ROOT=$1
if [ -z "$WS_ROOT" ]; then read -rp "workspace root (git root ที่มี workspaces/node-app): " WS_ROOT; fi
[ -z "$WS_ROOT" ] && { echo "Error: WORKSPACE_ROOT is required"; exit 1; }
WS_ROOT="$(cd "$WS_ROOT" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== [migration-v1.5.1] re-sync generic infra ==="
# ทั้งหมดของ 1.5.1 = เรียก utility sync-infra (copy generic files ที่ generator เป็นเจ้าของ ให้ตรง template)
bash "$SCRIPT_DIR/lib/sync-infra.sh" "$WS_ROOT" | sed 's/^/  /'

# NOTE: ไม่ bump template-version ที่นี่ — driver เขียน = 1.5.1 + log ให้หลัง rung นี้สำเร็จ
echo "=== [migration-v1.5.1] done ==="
