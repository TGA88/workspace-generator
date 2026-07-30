#!/bin/bash
# update-sb.sh <workspace-dir> <storybook-host-name>
#
# v1.7.1 — **thin wrapper**: delegate ไปที่ตัวจริง `template/workspace/tools/update_storybookhost_alias.sh`
#
# ── ทำไมเปลี่ยน ────────────────────────────────────────────────────────────────
# ไฟล์นี้เคยเป็น **สำเนาโค้ดทั้งดุ้น** ของ `update_storybookhost_alias.sh` (ตัวที่ถูก copy เข้า
# workspace ผ่าน `tools/`) — ก๊อป 2 ที่แล้วแก้ที่เดียว ⇒ **drift จริงแล้ว**: ตัวใน tools/ อัปเป็น
# `-name "ui-*"` (ครอบ ui-functions/ui-state-*) แต่ตัวนี้ยังค้างที่ list เดิม
# (`ui-*-lib`/`ui-components`/`ui-common`) ⇒ scaffold host ใหม่ได้ alias ไม่ครบ
# ส่วนที่ v1.7.1 แก้ (scope ตาม `stories` ของ host) ก็จะไม่ถึง path นี้ถ้ายังก๊อปกันอยู่
#
# ⇒ เหลือ implementation เดียว · ไฟล์นี้ทำหน้าที่แค่ resolve path จาก generator root
set -euo pipefail

WORKSPACE_DIR="${1:?usage: update-sb.sh <workspace-dir> <storybook-host-name>}"
PROJECT_NAME="${2:?usage: update-sb.sh <workspace-dir> <storybook-host-name>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"          # .../script-generator
TOOL="$SCRIPT_DIR/template/workspace/tools/update_storybookhost_alias.sh"

[ -f "$TOOL" ] || { echo "Error: ไม่พบ tool ที่ $TOOL" >&2; exit 1; }

exec bash "$TOOL" "$WORKSPACE_DIR" "$PROJECT_NAME"
