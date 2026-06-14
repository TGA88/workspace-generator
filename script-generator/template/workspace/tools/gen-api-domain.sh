#!/bin/bash
# Friendly wrapper for scaffolding a new API domain sub-module.
# Run from the pnpm workspace root (workspaces/node-app):
#   pnpm gen:api-domain <scope> <api-pkg> <domain>
#   e.g.  pnpm gen:api-domain shared-webapi shared-api order
#
# Assumes workspace-generator is cloned next to your workspace folder
# (override with: WORKSPACE_GENERATOR_DIR=/path/to/workspace-generator)
set -e
SCOPE=$1; API_PKG=$2; DOMAIN=$3
if [ -z "$DOMAIN" ]; then
  echo "usage: pnpm gen:api-domain <scope> <api-pkg> <domain>"
  echo "  e.g. pnpm gen:api-domain shared-webapi shared-api order"
  exit 1
fi
WS_ROOT="$(cd ../.. && pwd)"; WS_NAME="$(basename "$WS_ROOT")"
PARENT="$(cd ../../.. && pwd)"
GEN="${WORKSPACE_GENERATOR_DIR:-$PARENT/workspace-generator}"
if [ ! -d "$GEN/script-generator" ]; then
  echo "Error: workspace-generator not found at '$GEN'."
  echo "Clone it next to your workspace, or set WORKSPACE_GENERATOR_DIR."
  exit 1
fi
( cd "$PARENT" && bash "$GEN/script-generator/new-api-domain.sh" "$WS_NAME" "$SCOPE" "$API_PKG" "$DOMAIN" "$GEN" )
