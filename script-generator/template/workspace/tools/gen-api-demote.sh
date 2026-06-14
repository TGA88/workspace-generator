#!/bin/bash
# pnpm gen:api-demote [scope] [project] [shared-api]   — standalone project -> grouped domain (ไม่ใส่ param จะถาม)
set -e
SCOPE=$1; PROJECT=$2; SHARED=$3
if [ -z "$SCOPE" ];   then read -rp "scope (เช่น shared-webapi): " SCOPE; fi
if [ -z "$PROJECT" ]; then read -rp "standalone project (เช่น product-api): " PROJECT; fi
if [ -z "$SHARED" ];  then read -rp "target shared-api package (เช่น shared-api): " SHARED; fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
[ -d "$GEN/script-generator" ] || { echo "workspace-generator not found at $GEN (set WORKSPACE_GENERATOR_DIR)"; exit 1; }
( cd "$PARENT" && bash "$GEN/script-generator/demote-api-domain.sh" "$WS_NAME" "$SCOPE" "$PROJECT" "$SHARED" "$GEN" )
