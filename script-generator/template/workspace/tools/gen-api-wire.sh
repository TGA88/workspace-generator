#!/bin/bash
# pnpm gen:api-wire [scope] [api-pkg] [data-pkg] [webapi-app] [domain]   — ไม่ใส่ param จะถามให้ใส่ (TUI)
set -e
SCOPE=$1; API_PKG=$2; DATA_PKG=$3; WEBAPI_APP=$4; DOMAIN=$5
if [ -z "$SCOPE" ];      then read -rp "scope (เช่น shared-webapi): " SCOPE; fi
if [ -z "$API_PKG" ];    then read -rp "api package (เช่น shared-api): " API_PKG; fi
if [ -z "$DATA_PKG" ];   then read -rp "data package (มี store-prisma, เช่น demo-shop-data): " DATA_PKG; fi
if [ -z "$WEBAPI_APP" ]; then read -rp "webapi app (เช่น demo-shop-webapi): " WEBAPI_APP; fi
if [ -z "$DOMAIN" ];     then read -rp "domain (เช่น order): " DOMAIN; fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
if [ ! -d "$GEN/script-generator" ]; then echo "workspace-generator not found at $GEN (set WORKSPACE_GENERATOR_DIR)"; exit 1; fi
( cd "$PARENT" && bash "$GEN/script-generator/new-api-wire.sh" "$WS_NAME" "$SCOPE" "$API_PKG" "$DATA_PKG" "$WEBAPI_APP" "$DOMAIN" "$GEN" )
