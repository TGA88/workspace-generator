#!/bin/bash
# Scaffolding: generate a new API domain sub-module (command create-<domain> + query get-<domain>)
# into an existing shared-api package (core/service/client) using the unified-route pattern.
#
# usage: bash new-api-domain.sh <WORKSPACE> <SCOPE> <API_PKG> <DOMAIN> [GENERATOR_DIR]
#   WORKSPACE   = workspace/scope name (npm scope) e.g. demo-shop-system
#   SCOPE       = group folder under libs/ e.g. shared-webapi
#   API_PKG     = api package folder e.g. shared-api  (-> @<WORKSPACE>/<API_PKG>-{core,service,client})
#   DOMAIN      = domain base (lowercase, no -api) e.g. order  (-> order-api)
#   [LAYER]     = core|service|client|all (default all) — gen เฉพาะชั้นได้
set -e
# portable in-place sed: GNU = 'sed -i', BSD/macOS = 'sed -i \'\''
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
WORKSPACE=$1; SCOPE=$2; API_PKG=$3; DOMAIN=$4; GENERATOR_DIR=$5; LAYER=${6:-all}
SYSTEM_DIR='node-app'
[ -z "$GENERATOR_DIR" ] && { [ -d "workspace-generator" ] && GENERATOR_DIR="workspace-generator" || GENERATOR_DIR="."; }
# --- TUI: prompt for any missing arg (ไม่ใส่ param ก็ได้) ---
if [ -z "${WORKSPACE}" ]; then read -rp "workspace name (เช่น demo-shop-system): " WORKSPACE; fi
if [ -z "${SCOPE}" ]; then read -rp "scope (group folder ใต้ libs/, เช่น shared-webapi): " SCOPE; fi
if [ -z "${API_PKG}" ]; then read -rp "api package (เช่น shared-api): " API_PKG; fi
if [ -z "${DOMAIN}" ]; then read -rp "domain (เช่น order): " DOMAIN; fi
for v in WORKSPACE SCOPE API_PKG DOMAIN; do [ -z "${!v}" ] && { echo "Error: $v is required"; exit 1; }; done

# derive case variants
Domain="$(echo "$DOMAIN" | awk -F- '{r="";for(i=1;i<=NF;i++)r=r toupper(substr($i,1,1)) substr($i,2);print r}')"   # order -> Order, order-item -> OrderItem
DOMAINUP="$(echo "$DOMAIN" | tr 'a-z-' 'A-Z_')"               # order -> ORDER, order-item -> ORDER_ITEM

SC="$GENERATOR_DIR/script-generator/template/scaffold/api-domain"
BASE="$WORKSPACE/workspaces/$SYSTEM_DIR/libs/$SCOPE/$API_PKG"
echo "scaffold domain '$DOMAIN-api' (Domain=$Domain UPPER=$DOMAINUP) into $BASE/{core,service,client}"

tokenize_file() {
  sedi \
    -e "s/__DOMAIN_API__/${DOMAIN}-api/g" \
    -e "s/__DOMAINUP__/${DOMAINUP}/g" \
    -e "s/__Domain__/${Domain}/g" \
    -e "s/__domain__/${DOMAIN}/g" \
    -e "s/__DOMAIN__/${DOMAIN}/g" \
    -e "s/@__WS__/@${WORKSPACE}/g" \
    -e "s/__API__/${API_PKG}/g" \
    "$1"
}

for layer in core service client; do
  if [ "$LAYER" != "all" ] && [ "$LAYER" != "$layer" ]; then continue; fi
  SRC="$SC/$layer/__DOMAIN_API__"
  DEST="$BASE/$layer/src/${DOMAIN}-api"
  [ -d "$DEST" ] && { echo "  ! $DEST exists, skip $layer"; continue; }
  mkdir -p "$(dirname "$DEST")"
  cp -r "$SRC" "$DEST"
  # tokenize contents
  find "$DEST" -type f -name "*.ts" -print0 | while IFS= read -r -d '' f; do tokenize_file "$f"; done
  # rename path tokens — one basename at a time (handles nested tokens)
  while true; do
    p="$(find "$DEST" -depth -name '*__DOMAIN__*' | head -1)"
    [ -z "$p" ] && break
    mv "$p" "$(dirname "$p")/$(basename "$p" | sed "s/__DOMAIN__/${DOMAIN}/g")"
  done
  echo "  + $layer/src/${DOMAIN}-api"
done

# core: export domain registry from root index
if [ "$LAYER" = "all" ] || [ "$LAYER" = "core" ]; then
CIDX="$BASE/core/src/index.ts"
grep -q "'./${DOMAIN}-api'" "$CIDX" 2>/dev/null || echo "export * from './${DOMAIN}-api';" >> "$CIDX"
fi

# package.json exports for the domain (core/service/client)
add_exports() {
  local pkg="$1"; local layer="$2"
  node -e '
    const fs=require("fs");const f=process.argv[1],d=process.argv[2],layer=process.argv[3];
    const j=JSON.parse(fs.readFileSync(f));j.exports=j.exports||{};
    const mk=(sub)=>({development:`./src/${sub}`,import:`./dist/${sub.replace(/\.ts$/,".mjs")}`,require:`./dist/${sub.replace(/\.ts$/,".js")}`,types:`./dist/${sub.replace(/\.ts$/,".d.ts")}`});
    j.exports[`./${d}-api/command/*`]={development:`./src/${d}-api/command/*/index.ts`,import:`./dist/${d}-api/command/*/index.mjs`,require:`./dist/${d}-api/command/*/index.js`,types:`./dist/${d}-api/command/*/index.d.ts`};
    j.exports[`./${d}-api/query/*`]={development:`./src/${d}-api/query/*/index.ts`,import:`./dist/${d}-api/query/*/index.mjs`,require:`./dist/${d}-api/query/*/index.js`,types:`./dist/${d}-api/query/*/index.d.ts`};
    if(layer!=="service") j.exports[`./${d}-api`]={development:`./src/${d}-api/index.ts`,import:`./dist/${d}-api/index.mjs`,require:`./dist/${d}-api/index.js`,types:`./dist/${d}-api/index.d.ts`};
    fs.writeFileSync(f,JSON.stringify(j,null,2));
  ' "$pkg" "$DOMAIN" "$layer"
}
if [ "$LAYER" = "all" ] || [ "$LAYER" = "core" ];    then add_exports "$BASE/core/package.json" core; fi
if [ "$LAYER" = "all" ] || [ "$LAYER" = "service" ]; then add_exports "$BASE/service/package.json" service; fi
if [ "$LAYER" = "all" ] || [ "$LAYER" = "client" ];  then add_exports "$BASE/client/package.json" client; fi

echo "done: domain ${DOMAIN}-api scaffolded. add a data-layer repo + webapi route to wire it."
