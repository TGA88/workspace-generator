#!/bin/bash
# Scaffolding: add ONE action (command/query) to an EXISTING domain in shared-api.
# usage: bash new-api-action.sh <WORKSPACE> <SCOPE> <API_PKG> <DOMAIN> <command|query> <VERB> [GENERATOR_DIR] [LAYER]
#   VERB    = action verb e.g. update, delete, list  (action folder = <verb>-<domain>)
#   [LAYER] = core|service|client|all (default all)
set -e
WORKSPACE=$1; SCOPE=$2; API_PKG=$3; DOMAIN=$4; TYPE=$5; VERB=$6; GENERATOR_DIR=$7; LAYER=${8:-all}
SYSTEM_DIR='node-app'
[ -z "$GENERATOR_DIR" ] && { [ -d "workspace-generator" ] && GENERATOR_DIR="workspace-generator" || GENERATOR_DIR="."; }
for v in WORKSPACE SCOPE API_PKG DOMAIN TYPE VERB; do [ -z "${!v}" ] && { echo "Error: $v is required"; exit 1; }; done
[ "$TYPE" != "command" ] && [ "$TYPE" != "query" ] && { echo "Error: TYPE ต้องเป็น command หรือ query"; exit 1; }

Domain="$(echo "$DOMAIN" | sed -E 's/(^|-)([a-z])/\U\2/g')"; DOMAINUP="$(echo "$DOMAIN" | tr 'a-z-' 'A-Z_')"
Verb="$(echo "$VERB" | sed -E 's/(^|-)([a-z])/\U\2/g')"; VERBUP="$(echo "$VERB" | tr 'a-z-' 'A-Z_')"
SC="$GENERATOR_DIR/script-generator/template/scaffold/api-action/$TYPE"
BASE="$WORKSPACE/workspaces/$SYSTEM_DIR/libs/$SCOPE/$API_PKG"
ACTION="${VERB}-${DOMAIN}"
echo "scaffold action '$ACTION' ($TYPE) into ${DOMAIN}-api  [Verb=$Verb Domain=$Domain]"

tok() {
  sed -i \
    -e "s/__VERBUP__/${VERBUP}/g" -e "s/__Verb__/${Verb}/g" -e "s/__verb__/${VERB}/g" \
    -e "s/__DOMAINUP__/${DOMAINUP}/g" -e "s/__Domain__/${Domain}/g" -e "s/__domain__/${DOMAIN}/g" \
    -e "s/__REPO_KEY__/REPO_${VERBUP}_${DOMAINUP}/g" \
    -e "s/@__WS__/@${WORKSPACE}/g" -e "s/__API__/${API_PKG}/g" "$1"
}

for layer in core service client; do
  if [ "$LAYER" != "all" ] && [ "$LAYER" != "$layer" ]; then continue; fi
  DEST="$BASE/$layer/src/${DOMAIN}-api/${TYPE}/${ACTION}"
  if [ -d "$DEST" ]; then echo "  ! $DEST exists, skip"; continue; fi
  mkdir -p "$DEST"; cp -r "$SC/$layer/." "$DEST/"
  find "$DEST" -type f -name "*.ts" -print0 | while IFS= read -r -d '' f; do tok "$f"; done
  echo "  + $layer/src/${DOMAIN}-api/${TYPE}/${ACTION}"
done

# add DI key into core registry.const.ts (ถ้ายังไม่มี)
REG="$BASE/core/src/${DOMAIN}-api/registry.const.ts"
if [ -f "$REG" ] && ! grep -q "REPO_${VERBUP}_${DOMAINUP}:" "$REG"; then
  KEY="  REPO_${VERBUP}_${DOMAINUP}: '${Domain}Api.Repository.${Verb}${Domain}',"
  # แทรกก่อนบรรทัด '} as const;'
  awk -v k="$KEY" '/^} as const;/{print k} {print}' "$REG" > "$REG.tmp" && mv "$REG.tmp" "$REG"
  echo "  + registry key REPO_${VERBUP}_${DOMAINUP}"
fi
echo "done: action ${ACTION} scaffolded. แก้ field/logic + (ถ้า command) เพิ่ม repo+route ด้วย gen:api-wire pattern"
