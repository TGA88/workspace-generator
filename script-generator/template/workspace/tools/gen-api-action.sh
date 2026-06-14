#!/bin/bash
# pnpm gen:api-action [scope] [api-pkg] [domain] [command|query] [verb] [layer]  — ไม่ใส่ param จะถามให้ใส่ (TUI)
set -e
SCOPE=$1; API_PKG=$2; DOMAIN=$3; TYPE=$4; VERB=$5; LAYER=$6
if [ -z "$SCOPE" ];   then read -rp "scope (เช่น shared-webapi): " SCOPE; fi
if [ -z "$API_PKG" ]; then read -rp "api package (เช่น shared-api): " API_PKG; fi
if [ -z "$DOMAIN" ];  then read -rp "domain ที่มีอยู่ (เช่น order): " DOMAIN; fi
if [ -z "$TYPE" ];    then read -rp "type [command|query]: " TYPE; fi
if [ -z "$VERB" ];    then read -rp "verb (เช่น update, delete, list): " VERB; fi
if [ -z "$LAYER" ];   then read -rp "layer [core|service|client|all] (default all): " LAYER; fi
LAYER=${LAYER:-all}
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
if [ ! -d "$GEN/script-generator" ]; then echo "workspace-generator not found at $GEN (set WORKSPACE_GENERATOR_DIR)"; exit 1; fi
( cd "$PARENT" && bash "$GEN/script-generator/new-api-action.sh" "$WS_NAME" "$SCOPE" "$API_PKG" "$DOMAIN" "$TYPE" "$VERB" "$GEN" "$LAYER" )
