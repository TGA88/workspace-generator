#!/bin/bash
# Scaffolding: wire a domain to the data layer (store-prisma repo) + webapi route + prisma model.
# Run AFTER new-api-domain.sh has created the core/service/client slice for the domain.
#
# usage: bash new-api-wire.sh <WORKSPACE> <SCOPE> <API_PKG> <DATA_PKG> <WEBAPI_APP> <DOMAIN> [GENERATOR_DIR]
#   DATA_PKG    = data package folder (contains store-prisma) e.g. demo-shop-data
#   WEBAPI_APP  = webapi app folder (contains mcs-fastify) e.g. demo-shop-webapi
set -e
WORKSPACE=$1; SCOPE=$2; API_PKG=$3; DATA_PKG=$4; WEBAPI_APP=$5; DOMAIN=$6; GENERATOR_DIR=$7
SYSTEM_DIR='node-app'
[ -z "$GENERATOR_DIR" ] && { [ -d "workspace-generator" ] && GENERATOR_DIR="workspace-generator" || GENERATOR_DIR="."; }
for v in WORKSPACE SCOPE API_PKG DATA_PKG WEBAPI_APP DOMAIN; do [ -z "${!v}" ] && { echo "Error: $v is required"; exit 1; }; done

Domain="$(echo "$DOMAIN" | sed -E 's/(^|-)([a-z])/\U\2/g')"
DOMAINUP="$(echo "$DOMAIN" | tr 'a-z-' 'A-Z_')"
SC="$GENERATOR_DIR/script-generator/template/scaffold/api-wire"
NA="$WORKSPACE/workspaces/$SYSTEM_DIR"
STORE="$NA/libs/$SCOPE/$DATA_PKG/store-prisma"
WEBAPI="$NA/apps/$WEBAPI_APP/mcs-fastify"

tok() {
  sed -i \
    -e "s/__DOMAIN_API__/${DOMAIN}-api/g" -e "s/__DOMAINUP__/${DOMAINUP}/g" \
    -e "s/__Domain__/${Domain}/g" -e "s/__domain__/${DOMAIN}/g" -e "s/__DOMAIN__/${DOMAIN}/g" \
    -e "s/@__WS__/@${WORKSPACE}/g" -e "s/__API__/${API_PKG}/g" -e "s/__DATA__/${DATA_PKG}/g" "$1"
}

# ---- data-layer repo (store-prisma) ----
DF="$STORE/src/${DOMAIN}-factory"
for pair in "command/create-${DOMAIN}:__cmd__" "query/get-${DOMAIN}:__qry__"; do
  dest="$DF/${pair%%:*}"; srcname="${pair##*:}"
  if [ -d "$dest" ]; then echo "  ! $dest exists, skip"; else
    mkdir -p "$(dirname "$dest")"; cp -r "$SC/data/$srcname" "$dest"
    find "$dest" -type f -name "*.ts" -print0 | while IFS= read -r -d '' f; do tok "$f"; done
    echo "  + store-prisma/${DOMAIN}-factory/${pair%%:*}"
  fi
done

# ---- webapi routes ----
for pair in "create-${DOMAIN}:__cmd__.index.ts" "get-${DOMAIN}:__qry__.index.ts"; do
  dest="$WEBAPI/src/routes/${DOMAIN}-api/${pair%%:*}"; srcfile="${pair##*:}"
  if [ -d "$dest" ]; then echo "  ! $dest exists, skip"; else
    mkdir -p "$dest"; cp "$SC/route/$srcfile" "$dest/index.ts"; tok "$dest/index.ts"
    echo "  + routes/${DOMAIN}-api/${pair%%:*}"
  fi
done

# ---- prisma model (append if absent) ----
SCHEMA="$STORE/prisma/schema.prisma"
if grep -q "model ${Domain} " "$SCHEMA" 2>/dev/null; then echo "  ! model ${Domain} exists, skip"; else
  tmp="$(mktemp)"; cp "$SC/prisma/model.snippet" "$tmp"; tok "$tmp"; cat "$tmp" >> "$SCHEMA"; rm "$tmp"
  echo "  + prisma model ${Domain} (run: pnpm prisma:generate && pnpm gen:up-script)"
fi

# ---- store-prisma exports ----
node -e '
  const fs=require("fs");const f=process.argv[1],d=process.argv[2];
  const j=JSON.parse(fs.readFileSync(f));j.exports=j.exports||{};
  for (const [t,a] of [["command",`create-${d}`],["query",`get-${d}`]]) {
    const p=`${d}-factory/${t}/${a}/index`;
    j.exports[`./${d}-api/${t}/${a}`]={development:`./src/${p}.ts`,import:`./dist/${p}.mjs`,types:`./dist/${p}.d.ts`,require:`./dist/${p}.js`};
  }
  fs.writeFileSync(f,JSON.stringify(j,null,2));
' "$STORE/package.json" "$DOMAIN"

echo "wired ${DOMAIN}: store-prisma repo + webapi route + prisma model. run prisma:generate + migration."
