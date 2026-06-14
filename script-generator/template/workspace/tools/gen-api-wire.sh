#!/bin/bash
# Friendly wrapper: wire a domain to data-layer (store-prisma) + webapi route + prisma model.
# Run from workspaces/node-app AFTER gen:api-domain:
#   pnpm gen:api-wire <scope> <api-pkg> <data-pkg> <webapi-app> <domain>
#   e.g. pnpm gen:api-wire shared-webapi shared-api demo-shop-data demo-shop-webapi order
set -e
SCOPE=$1; API_PKG=$2; DATA_PKG=$3; WEBAPI_APP=$4; DOMAIN=$5
if [ -z "$DOMAIN" ]; then
  echo "usage: pnpm gen:api-wire <scope> <api-pkg> <data-pkg> <webapi-app> <domain>"; exit 1
fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"; PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
[ -d "$GEN/script-generator" ] || { echo "workspace-generator not found at $GEN"; exit 1; }
( cd "$PARENT" && bash "$GEN/script-generator/new-api-wire.sh" "$WS_NAME" "$SCOPE" "$API_PKG" "$DATA_PKG" "$WEBAPI_APP" "$DOMAIN" "$GEN" )
