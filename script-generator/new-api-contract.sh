#!/bin/bash
# Scaffolding: create the contract ⇄ backend-test PAIR for an action (§8.2).
#   infrastructure/contract/<service>/<domain>-api/<action>/  (c1/e1.json + setup/teardown.sql + _cases.json)
#   backend-test/<service>/<domain>-api/<action>.test.ts       (node:test, วน _cases.json)
# + ensure domain seed folder + liquibase changeSet (context=seed, label=domain:<domain>-api) ครั้งเดียว/domain
#
# usage: bash new-api-contract.sh <WORKSPACE> <SERVICE> <DOMAIN> [ACTION] [GENERATOR_DIR]
#   SERVICE = webapi app e.g. demo-shop-webapi · DOMAIN = base e.g. product (-> product-api)
#   ACTION  = <verb>-<domain> e.g. create-product · ว่าง = create-<domain> + get-<domain> (default)
set -e
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
WORKSPACE=$1; SERVICE=$2; DOMAIN=$3; ACTION=$4; GENERATOR_DIR=$5
[ -z "$GENERATOR_DIR" ] && { [ -d "workspace-generator" ] && GENERATOR_DIR="workspace-generator" || GENERATOR_DIR="."; }
if [ -z "${WORKSPACE}" ]; then read -rp "workspace name (เช่น demo-shop-system): " WORKSPACE; fi
if [ -z "${SERVICE}" ];   then read -rp "service = webapi app (เช่น demo-shop-webapi): " SERVICE; fi
if [ -z "${DOMAIN}" ];    then read -rp "domain base (เช่น product): " DOMAIN; fi
for v in WORKSPACE SERVICE DOMAIN; do [ -z "${!v}" ] && { echo "Error: $v is required"; exit 1; }; done

Domain="$(echo "$DOMAIN" | awk -F- '{r="";for(i=1;i<=NF;i++)r=r toupper(substr($i,1,1)) substr($i,2);print r}')"
DOMAIN_API="${DOMAIN}-api"
SC="$GENERATOR_DIR/script-generator/template/scaffold/api-contract"
ROOT="$WORKSPACE"
INFRA="$ROOT/workspaces/infrastructure"
BT="$ROOT/workspaces/backend-test"

# actions: ใช้ตามที่ระบุ · ว่าง = default create-<domain> + get-<domain> (mirror gen:api-wire)
ACTIONS="$ACTION"
[ -z "$ACTIONS" ] && ACTIONS="create-${DOMAIN} get-${DOMAIN}"

method_of() {  # verb -> HTTP method
  case "${1%%-*}" in
    get|list|find|search|query) echo get ;;
    update|edit|patch)          echo put ;;
    delete|remove)              echo delete ;;
    *)                          echo post ;;
  esac
}
tok() {  # $1=action  $2=file
  local act="$1"; local verb="${act%%-*}"; local method; method="$(method_of "$act")"
  sedi \
    -e "s/__ACTION__/${act}/g" -e "s/__METHOD__/${method}/g" -e "s/__VERB__/${verb}/g" \
    -e "s/__DOMAIN_API__/${DOMAIN_API}/g" -e "s/__Domain__/${Domain}/g" -e "s/__DOMAIN__/${DOMAIN}/g" \
    -e "s/__SERVICE__/${SERVICE}/g" -e "s/@__WS__/@${WORKSPACE}/g" "$2"
}

echo "scaffold contract⇄test pair(s) for ${DOMAIN_API} @ ${SERVICE}: ${ACTIONS}"

for act in $ACTIONS; do
  # ---- contract folder (SSOT) ----
  CDEST="$INFRA/contract/$SERVICE/$DOMAIN_API/$act"
  if [ -d "$CDEST" ]; then echo "  ! contract/$SERVICE/$DOMAIN_API/$act exists, skip"; else
    mkdir -p "$CDEST"; cp "$SC/contract/"* "$CDEST/"
    for f in "$CDEST"/*; do tok "$act" "$f"; done
    echo "  + contract/$SERVICE/$DOMAIN_API/$act (c1/e1.json + setup/teardown.sql + _cases.json)"
  fi
  # ---- backend-test file (คู่กัน) ----
  TDEST="$BT/$SERVICE/$DOMAIN_API"
  if [ -f "$TDEST/$act.test.ts" ]; then echo "  ! backend-test/$SERVICE/$DOMAIN_API/$act.test.ts exists, skip"; else
    mkdir -p "$TDEST"; cp "$SC/test/__ACTION__.test.ts" "$TDEST/$act.test.ts"; tok "$act" "$TDEST/$act.test.ts"
    echo "  + backend-test/$SERVICE/$DOMAIN_API/$act.test.ts"
  fi
done

# ---- domain seed folder + liquibase changeSet (idempotent, ครั้งเดียว/domain) ----
SEED_ROOT="$(find "$INFRA/db" -maxdepth 2 -type d -name seed 2>/dev/null | head -1)"
if [ -z "$SEED_ROOT" ]; then
  echo "  ! ไม่พบ infrastructure/db/<db-schema>/seed — รัน gen:infra ก่อน (ข้าม domain seed)"
else
  DB_SCHEMA_DIR="$(basename "$(dirname "$SEED_ROOT")")"
  DSEED="$SEED_ROOT/$DOMAIN_API"
  if [ ! -d "$DSEED" ]; then
    mkdir -p "$DSEED"; cp "$SC/seed/base.sql" "$DSEED/base.sql"
    sedi -e "s/__DOMAIN_API__/${DOMAIN_API}/g" -e "s/__DOMAIN__/${DOMAIN}/g" "$DSEED/base.sql"
    echo "  + db/$DB_SCHEMA_DIR/seed/$DOMAIN_API/base.sql"
  fi
  CHANGELOG="$INFRA/liquibase/changelog.yaml"
  if [ -f "$CHANGELOG" ] && ! grep -q "id: seed-${DOMAIN_API}\b" "$CHANGELOG"; then
    if grep -q "GEN:DOMAIN-SEED-ANCHOR" "$CHANGELOG"; then
      BLOCK="$(mktemp "${TMPDIR:-/tmp}/dseed.XXXXXX")"
      cat > "$BLOCK" <<EOF
  - changeSet:
      id: seed-${DOMAIN_API}
      author: gen
      context: seed
      labels: domain:${DOMAIN_API}
      changes:
        - sqlFile: { path: db/${DB_SCHEMA_DIR}/seed/${DOMAIN_API}/base.sql, relativeToChangelogFile: false }
EOF
      awk -v bf="$BLOCK" '/GEN:DOMAIN-SEED-ANCHOR/{while((getline l<bf)>0)print l; close(bf)} {print}' \
        "$CHANGELOG" > "$CHANGELOG.tmp" && mv "$CHANGELOG.tmp" "$CHANGELOG"
      rm -f "$BLOCK"
      echo "  + changeSet seed-${DOMAIN_API} (context=seed, label=domain:${DOMAIN_API})"
    else
      echo "  ! ไม่พบ anchor ใน changelog.yaml — ข้าม changeSet (เพิ่มเองได้)"
    fi
  fi
fi

echo "done: pair(s) scaffolded. แก้ envelope (body/headers) + setup/teardown ตาม action จริง"
