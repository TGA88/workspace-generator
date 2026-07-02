#!/bin/bash
# Migration v1.4 → v1.5 : add backend-test + infrastructure layer to an EXISTING workspace.
# full-auto + idempotent — orchestrates new-infrastructure.sh + new-api-contract.sh, wires prisma
# migrations into the infra changelog, bumps template-version.
#
# usage: bash apply-backend-test-infra.sh <WORKSPACE_ROOT> [SERVICE] [DB_SCHEMA]
#   WORKSPACE_ROOT = git root of the target workspace (มี workspaces/node-app)
#   [SERVICE]      = webapi app (default: auto-detect apps/*/mcs-fastify)
#   [DB_SCHEMA]    = db-schema folder (default: <data-pkg> ตัด -data · เช่น demo-shop)
#
# ⚠️ workspace < 1.4 ควรรัน apply-export-strategy.mjs ก่อน (นำ workspace ขึ้น 1.4 semantics) แล้วค่อยตัวนี้
set -e
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }

WS_ROOT=$1; SERVICE_ARG=$2; DB_SCHEMA_ARG=$3
if [ -z "$WS_ROOT" ]; then read -rp "workspace root (git root ที่มี workspaces/node-app): " WS_ROOT; fi
[ -z "$WS_ROOT" ] && { echo "Error: WORKSPACE_ROOT is required"; exit 1; }
WS_ROOT="$(cd "$WS_ROOT" && pwd)"
PARENT="$(dirname "$WS_ROOT")"; WS_NAME="$(basename "$WS_ROOT")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"; GEN="$(cd "$SCRIPT_DIR/../.." && pwd)"
NA="$WS_ROOT/workspaces/node-app"

# precondition
[ -f "$NA/pnpm-workspace.yaml" ] || { echo "Error: $NA/pnpm-workspace.yaml ไม่พบ — ไม่ใช่ workspace ที่ถูกต้อง"; exit 1; }
[ -f "$GEN/script-generator/new-infrastructure.sh" ] || { echo "Error: generator ไม่พบที่ $GEN"; exit 1; }

echo "=== [v1.5 migrate] $WS_NAME ==="

# ── auto-derive args ──
STORE="$(find "$NA/libs" -maxdepth 4 -type d -name store-prisma 2>/dev/null | head -1)"
[ -z "$STORE" ] && { echo "Error: ไม่พบ store-prisma ใน $NA/libs"; exit 1; }
DATA_PKG="$(basename "$(dirname "$STORE")")"                    # demo-shop-data
SCOPE="$(basename "$(dirname "$(dirname "$STORE")")")"          # shared-webapi
CORE_DIR="$(find "$NA/libs/$SCOPE" -maxdepth 2 -type d -name core 2>/dev/null | head -1)"
API_PKG="$(basename "$(dirname "$CORE_DIR")")"                  # shared-api
if [ -n "$SERVICE_ARG" ]; then SERVICE="$SERVICE_ARG"; else
  SERVICE="$(basename "$(dirname "$(find "$NA/apps" -maxdepth 2 -type d -name mcs-fastify 2>/dev/null | head -1)")")"
fi
DB_SCHEMA="${DB_SCHEMA_ARG:-${DATA_PKG%-data}}"                 # demo-shop
echo "  derived: service=$SERVICE db-schema=$DB_SCHEMA scope=$SCOPE data=$DATA_PKG api=$API_PKG"
for v in SERVICE DB_SCHEMA SCOPE DATA_PKG API_PKG; do [ -z "${!v}" ] && { echo "Error: derive $v ไม่ได้"; exit 1; }; done

# ── Step 1: infrastructure + backend-test + root Makefile (idempotent) ──
echo "  [1/5] infrastructure + backend-test"
( cd "$PARENT" && bash "$GEN/script-generator/new-infrastructure.sh" "$WS_NAME" "$SERVICE" "$DB_SCHEMA" "$SCOPE" "$DATA_PKG" "$API_PKG" "$GEN" ) | sed 's/^/      /'

# ── Step 2: webapi Dockerfile (nx multi-stage) + node-app .dockerignore (build tooling — ไม่แตะ app source) ──
# ⚠️ ไม่ patch app.ts / create-telemetry (app config = ของ app-owner) · telemetry+prefix จัดการผ่าน compose/_config
echo "  [2/5] webapi Dockerfile + .dockerignore"
APPDIR="$NA/apps/$SERVICE/mcs-fastify"
DF="$APPDIR/Dockerfile"
DF_TPL="$GEN/script-generator/template/project/webapi/mcs-fastify/Dockerfile"
sed_df() { sedi -e "s/demo-exm-webapi/${SERVICE}/g" -e "s/gu-example-system/${WS_NAME}/g" -e "s/exm-data/${DATA_PKG}/g" "$1"; }
if [ -f "$DF" ] && grep -q 'AS build' "$DF"; then
  echo "      ! Dockerfile = multi-stage แล้ว, skip"
elif [ ! -f "$DF" ] || grep -q 'COPY /dist/apps' "$DF"; then
  cp "$DF_TPL" "$DF"; sed_df "$DF"; echo "      + Dockerfile → nx multi-stage (แทน placeholder)"
else
  cp "$DF_TPL" "$APPDIR/Dockerfile.backend-test.example"; sed_df "$APPDIR/Dockerfile.backend-test.example"
  echo "      ! Dockerfile ถูก customize → เขียน Dockerfile.backend-test.example (merge เอง)"
fi
[ -f "$NA/.dockerignore" ] || { cp "$GEN/script-generator/template/workspace/.dockerignore" "$NA/.dockerignore"; echo "      + node-app/.dockerignore"; }

# ── Step 3: discover domains/actions → contract+test pair (idempotent) ──
echo "  [3/5] backfill contract+test pairs (จาก core domains ที่มี)"
CORE="$NA/libs/$SCOPE/$API_PKG/core/src"
for d in "$CORE"/*-api/; do
  [ -d "$d" ] || continue
  DOMAIN_API="$(basename "$d")"; DOMAIN="${DOMAIN_API%-api}"
  ACTIONS="$(find "$d/command" "$d/query" -mindepth 1 -maxdepth 1 -type d ! -name repository ! -name '__test*' 2>/dev/null -exec basename {} \; | sort)"
  [ -z "$ACTIONS" ] && continue
  for act in $ACTIONS; do
    ( cd "$PARENT" && bash "$GEN/script-generator/new-api-contract.sh" "$WS_NAME" "$SERVICE" "$DOMAIN" "$act" "$GEN" ) | sed 's/^/      /'
  done
done

# ── Step 4: wire real prisma migrations into infra changelog (migrate context) ──
echo "  [4/5] wire prisma migrations → changelog (context=migrate)"
CHANGELOG="$WS_ROOT/workspaces/infrastructure/liquibase/changelog.yaml"
MIGDIR="$STORE/prisma/migrations"
if [ ! -f "$CHANGELOG" ]; then echo "      ! ไม่พบ changelog.yaml — ข้าม"; else
  if ! grep -q "GEN:MIGRATE-ANCHOR" "$CHANGELOG"; then echo "      ! ไม่พบ MIGRATE-ANCHOR ใน changelog — ข้าม (เพิ่ม anchor เองได้)"; else
    for m in $(find "$MIGDIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort); do
      [ -f "$m/migration.sql" ] || continue
      fname="$(basename "$m")"
      grep -q "id: migrate-${fname}\b" "$CHANGELOG" && { echo "      ! migrate-${fname} มีแล้ว, skip"; continue; }
      BLOCK="$(mktemp "${TMPDIR:-/tmp}/mig.XXXXXX")"
      {
        echo "  - changeSet:"
        echo "      id: migrate-${fname}"
        echo "      author: gen"
        echo "      context: migrate"
        echo "      labels: schema"
        echo "      changes:"
        echo "        - sqlFile:"
        echo "            path: prisma/migrations/${fname}/migration.sql"
        echo "            relativeToChangelogFile: false"
        if [ -f "$m/down.sql" ]; then
          echo "        - rollback:"
          echo "            - sqlFile:"
          echo "                path: prisma/migrations/${fname}/down.sql"
          echo "                relativeToChangelogFile: false"
        fi
      } > "$BLOCK"
      awk -v bf="$BLOCK" '/GEN:MIGRATE-ANCHOR/{while((getline l<bf)>0)print l; close(bf)} {print}' \
        "$CHANGELOG" > "$CHANGELOG.tmp" && mv "$CHANGELOG.tmp" "$CHANGELOG"
      rm -f "$BLOCK"
      echo "      + changeSet migrate-${fname} ($([ -f "$m/down.sql" ] && echo '+rollback' || echo 'no down.sql'))"
    done
  fi
fi

# ── Step 5: bump template-version ──
echo "  [5/5] template-version"
VERFILE="$NA/template-version"
if [ -f "$VERFILE" ]; then
  CUR="$(cat "$VERFILE" 2>/dev/null | tr -d '[:space:]')"
  if [ "$CUR" = "1.5.0" ]; then echo "      ! already 1.5.0"; else echo "1.5.0" > "$VERFILE"; echo "      + template-version ${CUR:-?} → 1.5.0"; fi
else
  echo "1.5.0" > "$VERFILE"; echo "      + template-version (new) → 1.5.0"
fi

echo "=== [v1.5 migrate] done ==="
echo "  auto: infra + backend-test (pure harness + per-service _config) + webapi Dockerfile(nx) + .dockerignore + wire migration"
echo "  manual ที่เหลือ (dev):"
echo "    (1) cd workspaces/node-app && pnpm install   (store-prisma postinstall → prisma generate)"
echo "    (2) cd workspaces/backend-test && pnpm install"
echo "    (3) แก้ contract envelope (body/headers/auth) + assertDb ให้ตรง action จริง (skeleton → meaningful)"
echo "    (4) เพิ่ม endpoint/action นอกเหนือที่ core มี (ถ้าต้องการ) ด้วย gen:api-action + wire"
echo "    (5) make api-test  (bring-up สด → node:test → down)"
echo "  telemetry: compose api ตั้ง OTEL env ให้แล้ว (Console provider พังใน core@0.3.4) · prefix: _config.ts (TARGET.prefix)"
