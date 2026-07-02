#!/bin/bash
# Scaffolding: create workspaces/infrastructure + workspaces/backend-test + root Makefile
# (one-time per system) — โครง contract(SSOT)/db/liquibase/docker-compose + node:test harness
#
# usage: bash new-infrastructure.sh <WORKSPACE> <SERVICE> <DB_SCHEMA> [SCOPE] [DATA_PKG] [API_PKG] [GENERATOR_DIR]
#   WORKSPACE   = workspace/scope name (npm scope) e.g. demo-shop-system
#   SERVICE     = webapi app (service) folder e.g. demo-shop-webapi  (-> contract/ + backend-test/ group)
#   DB_SCHEMA   = db-schema folder (kebab) e.g. demo-shop   (-> db/<db-schema>/ · schema name = UPPER)
#   [SCOPE]     = libs group (default shared-webapi)
#   [DATA_PKG]  = data package with store-prisma (default <DB_SCHEMA>-data)
#   [API_PKG]   = api package (default shared-api) — ใช้ใน conformance import ตัวอย่าง
set -e
# portable in-place sed: GNU = 'sed -i', BSD/macOS = 'sed -i \'\''
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
WORKSPACE=$1; SERVICE=$2; DB_SCHEMA=$3; SCOPE=$4; DATA_PKG=$5; API_PKG=$6; GENERATOR_DIR=$7
SYSTEM_DIR='node-app'
[ -z "$GENERATOR_DIR" ] && { [ -d "workspace-generator" ] && GENERATOR_DIR="workspace-generator" || GENERATOR_DIR="."; }
# --- TUI: prompt for any missing arg (ไม่ใส่ param ก็ได้) ---
if [ -z "${WORKSPACE}" ]; then read -rp "workspace name (เช่น demo-shop-system): " WORKSPACE; fi
if [ -z "${SERVICE}" ];   then read -rp "service = webapi app (เช่น demo-shop-webapi): " SERVICE; fi
if [ -z "${DB_SCHEMA}" ]; then read -rp "db-schema folder (เช่น demo-shop): " DB_SCHEMA; fi
for v in WORKSPACE SERVICE DB_SCHEMA; do [ -z "${!v}" ] && { echo "Error: $v is required"; exit 1; }; done
SCOPE=${SCOPE:-shared-webapi}
DATA_PKG=${DATA_PKG:-${DB_SCHEMA}-data}
API_PKG=${API_PKG:-shared-api}

# derive db names (ARCH-STD-001: schema = [Company]_[Platform]_[System] — demo ใช้ system upper เป็น placeholder)
DB_UP="$(echo "$DB_SCHEMA" | tr 'a-z-' 'A-Z_')"          # demo-shop -> DEMO_SHOP
# schema = lowercase: postgres fold-case identifier ที่ไม่ quote (CREATE SCHEMA/DDL) → ถ้าใช้ UPPER
# แล้ว prisma/harness อ้าง schema แบบ quote จะ mismatch (หา "DEMO_SHOP" ไม่เจอ เพราะจริงเป็น demo_shop)
DB_SCHEMA_NAME="$(echo "$DB_SCHEMA" | tr 'a-z-' 'a-z_')"  # demo-shop -> demo_shop (postgres schema)
DB_NAME="${DB_UP}_DATA_INTEGRATION"                       # postgres database (POSTGRES_DB คงเคสได้)

TPL="$GENERATOR_DIR/script-generator/template"
ROOT="$WORKSPACE"                                         # git root
INFRA="$ROOT/workspaces/infrastructure"
BT="$ROOT/workspaces/backend-test"

echo "scaffold infrastructure + backend-test for '$WORKSPACE'"
echo "  service=$SERVICE db-schema=$DB_SCHEMA (name=$DB_SCHEMA_NAME db=$DB_NAME) scope=$SCOPE data=$DATA_PKG api=$API_PKG"

# token replace — ⚠️ __DB_SCHEMA_NAME__ ก่อน __DB_SCHEMA__ · @__WS__ ก่อน __WS__
tok() {
  sedi \
    -e "s/@__WS__/@${WORKSPACE}/g" -e "s/__WS__/${WORKSPACE}/g" \
    -e "s/__SERVICE__/${SERVICE}/g" -e "s/__SCOPE__/${SCOPE}/g" \
    -e "s/__DATA_PKG__/${DATA_PKG}/g" -e "s/__API__/${API_PKG}/g" \
    -e "s/__DB_SCHEMA_NAME__/${DB_SCHEMA_NAME}/g" -e "s/__DB_NAME__/${DB_NAME}/g" \
    -e "s/__DB_SCHEMA__/${DB_SCHEMA}/g" "$1"
}
tokenize_tree() { find "$1" -type f -print0 | while IFS= read -r -d '' f; do tok "$f"; done; }
rename_token() {  # rename path token <TOKEN> -> <VALUE> under $1 (deepest-first)
  local base="$1" token="$2" value="$3"
  while true; do
    p="$(find "$base" -depth -name "*${token}*" | head -1)"; [ -z "$p" ] && break
    np="$(dirname "$p")/$(basename "$p" | sed "s/${token}/${value}/g")"; [ "$p" = "$np" ] && break; mv "$p" "$np"
  done
}

# ---- infrastructure ----
# guard = docker-compose.yml (ไม่ใช่แค่ dir) — เผื่อ gen:api-contract สร้าง contract/ ไว้ก่อน (merge เข้า)
if [ -f "$INFRA/docker-compose.yml" ]; then echo "  ! infrastructure/docker-compose.yml exists, skip infrastructure"; else
  mkdir -p "$INFRA"; cp -r "$TPL/infrastructure/." "$INFRA/"   # merge (คง contract/ ที่มีอยู่)
  rename_token "$INFRA" "__DB_SCHEMA__" "$DB_SCHEMA"
  tokenize_tree "$INFRA"
  echo "  + workspaces/infrastructure (contract/ db/$DB_SCHEMA liquibase docker-compose)"
fi

# ---- backend-test ----
if [ -d "$BT" ]; then echo "  ! $BT exists, skip backend-test"; else
  mkdir -p "$(dirname "$BT")"; cp -r "$TPL/backend-test" "$BT"
  rename_token "$BT" "__SERVICE__" "$SERVICE"
  tokenize_tree "$BT"
  echo "  + workspaces/backend-test (node:test harness + _conformance)"
fi

# ---- root Makefile ----
if [ -f "$ROOT/Makefile" ]; then
  cp "$TPL/workspace/root/Makefile" "$ROOT/Makefile.backend-test.example"; tok "$ROOT/Makefile.backend-test.example"
  echo "  ! root Makefile exists → เขียน Makefile.backend-test.example ให้ merge เอง"
else
  cp "$TPL/workspace/root/Makefile" "$ROOT/Makefile"; tok "$ROOT/Makefile"
  echo "  + Makefile (root entrypoint: up/migrate/init/seed/api-up/test/down/api-test)"
fi

# ---- root convention files (idempotent — เผื่อ gen:infra ถูกรันเดี่ยว) ----
[ -f "$ROOT/.gitattributes" ] || cp "$TPL/workspace/root/.gitattributes" "$ROOT/.gitattributes"
[ -f "$ROOT/.editorconfig" ]  || cp "$TPL/workspace/root/.editorconfig"  "$ROOT/.editorconfig"

echo "done: infrastructure + backend-test scaffolded."
echo "  next: (1) cd workspaces/backend-test && pnpm install   (2) gen:api-contract ต่อ action   (3) make api-test"
