#!/bin/bash
# pnpm gen:infra [service] [db-schema] [scope] [data-pkg] [api-pkg]  — ไม่ใส่ param จะถามให้ใส่ (TUI)
# one-time per system: สร้าง workspaces/infrastructure + workspaces/backend-test + root Makefile
set -e
SERVICE=$1; DB_SCHEMA=$2; SCOPE=$3; DATA_PKG=$4; API_PKG=$5
if [ -z "$SERVICE" ];   then read -rp "service = webapi app (เช่น demo-shop-webapi): " SERVICE; fi
if [ -z "$DB_SCHEMA" ]; then read -rp "db-schema folder (เช่น demo-shop): " DB_SCHEMA; fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
if [ ! -d "$GEN/script-generator" ]; then echo "workspace-generator not found at $GEN (set WORKSPACE_GENERATOR_DIR)"; exit 1; fi
( cd "$PARENT" && bash "$GEN/script-generator/new-infrastructure.sh" "$WS_NAME" "$SERVICE" "$DB_SCHEMA" "$SCOPE" "$DATA_PKG" "$API_PKG" "$GEN" )
