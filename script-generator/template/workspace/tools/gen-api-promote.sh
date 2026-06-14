#!/bin/bash
# pnpm gen:api-promote [scope] [shared-api] [domain]   — grouped domain -> standalone project (ไม่ใส่ param จะถาม)
set -e
SCOPE=$1; SHARED=$2; DOMAIN=$3
if [ -z "$SCOPE" ];  then read -rp "scope (เช่น shared-webapi): " SCOPE; fi
if [ -z "$SHARED" ]; then read -rp "shared-api package (เช่น shared-api): " SHARED; fi
if [ -z "$DOMAIN" ]; then read -rp "domain ที่จะ promote (เช่น product): " DOMAIN; fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
[ -d "$GEN/script-generator" ] || { echo "workspace-generator not found at $GEN (set WORKSPACE_GENERATOR_DIR)"; exit 1; }
( cd "$PARENT" && bash "$GEN/script-generator/promote-api-domain.sh" "$WS_NAME" "$SCOPE" "$SHARED" "$DOMAIN" "$GEN" )
