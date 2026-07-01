#!/bin/bash
# pnpm gen:api-contract [service] [domain] [action]  — ไม่ใส่ param จะถามให้ใส่ (TUI)
# สร้างคู่กัน: infrastructure/contract/<service>/<domain>-api/<action>/ + backend-test/.../<action>.test.ts
# (gen:api-wire เรียกให้อัตโนมัติแล้ว — ใช้อันนี้ตอนเพิ่ม action เดี่ยว หรือ regenerate)
set -e
SERVICE=$1; DOMAIN=$2; ACTION=$3
if [ -z "$SERVICE" ]; then read -rp "service = webapi app (เช่น demo-shop-webapi): " SERVICE; fi
if [ -z "$DOMAIN" ];  then read -rp "domain base ไม่ใส่ -api (เช่น product): " DOMAIN; fi
if [ -z "$ACTION" ];  then read -rp "action (เช่น update-product · ว่าง = create+get): " ACTION; fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
if [ ! -d "$GEN/script-generator" ]; then echo "workspace-generator not found at $GEN (set WORKSPACE_GENERATOR_DIR)"; exit 1; fi
( cd "$PARENT" && bash "$GEN/script-generator/new-api-contract.sh" "$WS_NAME" "$SERVICE" "$DOMAIN" "$ACTION" "$GEN" )
