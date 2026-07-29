#!/bin/bash
# migration-v1.7.0.sh — Migration → v1.7.0 : web scaffold mode (standalone|static) + template fixes
#
# ⚠️ **NO-OP โดยตั้งใจ** — v1.7.0 แตะเฉพาะ *template ที่ใช้ตอน gen โปรเจกต์ใหม่* กับ `new-web.sh`
# ไม่มีอะไรใน workspace ที่ generate ไปแล้วต้องถูกแก้:
#   · template/project/web/**            → ใช้ตอน `new-web.sh` เท่านั้น (แอปที่มีอยู่แล้วไม่ถูกแตะ)
#   · template/project/web/nextjs-static-overlay/** (ใหม่) → เหมือนกัน
#   · script-generator/new-web.sh        → รันจาก generator repo ไม่ได้ถูก copy เข้า workspace
# ไม่เรียก lib/sync-infra.sh เพราะ **ไม่มีไฟล์ generator-owned ตัวไหนเปลี่ยน** (tools/, Dockerfile.verify-*,
# compose ฯลฯ เหมือน v1.6.0 ทุกไบต์) — เรียกไปก็มีแต่ความเสี่ยงทับ customization ของ repo โดยไม่ได้อะไร
#
# ที่ต้องมีไฟล์นี้ทั้งที่ไม่ทำอะไร: contract §3.2 กำหนดว่า **ทุกเวอร์ชัน (minor/patch) = 1 ไฟล์
# migration-v<semver>** เพื่อให้ ladder ต่อเนื่อง — driver ไล่ทีละขั้น ขาดขั้นไหน = ข้ามไม่ได้
#
# ⚠️ แอปที่ gen ก่อน v1.7.0 แล้วแปลงเป็น static export ด้วยมือ (เช่น auth-portal portal-web ตอน P-PW.0
# และ admin-portal-web ตอน P-PW.5c) **ยังถูกต้องอยู่** — v1.7.0 แค่ทำให้แอป *ตัวถัดไป* ไม่ต้องทำมือซ้ำ
#
# contract: ห้ามเขียน template-version / log เอง (driver ทำให้)
set -euo pipefail

WORKSPACE_DIR="${1:?usage: migration-v1.7.0.sh <workspace-dir>}"

if [ ! -d "$WORKSPACE_DIR" ]; then
  echo "ERROR: ไม่พบ workspace dir: $WORKSPACE_DIR"
  exit 1
fi

echo "migration v1.7.0: no-op — template-only release (web scaffold mode)"
echo "  · โปรเจกต์ใหม่: new-web.sh <ws> <name> [gen-dir] [standalone|static]  (default standalone)"
echo "  · แอปที่มีอยู่แล้วใน $WORKSPACE_DIR ไม่ถูกแตะ"
exit 0
