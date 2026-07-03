#!/bin/bash
# migration-v1.5.0.sh — Migration → v1.5.0 : add backend-test + infrastructure layer to a workspace.
# full-auto + idempotent — orchestrates new-infrastructure.sh + new-api-contract.sh, wires prisma
# migrations into the infra changelog.
#
# ⚙️ ปกติรันผ่าน driver: `bash apply-migration.sh <ws>` (driver จัดลำดับ + bump template-version + เขียน log ให้)
#    รันตรงก็ได้ (ไม่ bump version/ไม่ log): bash migration-v1.5.0.sh <WORKSPACE_ROOT> [SERVICE] [DB_SCHEMA]
#   WORKSPACE_ROOT = git root of the target workspace (มี workspaces/node-app)
#   [SERVICE]      = webapi app (default: auto-detect apps/*/mcs-fastify)
#   [DB_SCHEMA]    = db-schema folder (default: <data-pkg> ตัด -data · เช่น demo-shop)
#
# ⚠️ ต้องผ่าน migration-v1.4.0 (export-strategy) มาก่อน — driver จัดลำดับให้ (rung นี้พึ่ง semantics 1.4)
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
echo "  [1/4] infrastructure + backend-test"
( cd "$PARENT" && bash "$GEN/script-generator/new-infrastructure.sh" "$WS_NAME" "$SERVICE" "$DB_SCHEMA" "$SCOPE" "$DATA_PKG" "$API_PKG" "$GEN" ) | sed 's/^/      /'

# ── Step 2: webapi build Dockerfiles (.build + .nx-build · token → sed) + generic infra re-sync (lib/sync-infra.sh) ──
# ⚠️ ไม่ patch app.ts / create-telemetry (app config = ของ app-owner) · telemetry+prefix จัดการผ่าน compose/_config
# ⚠️ ไม่แตะ `Dockerfile` เดิม (runtime-only ของ CI release→docker:build) — เพิ่มแค่ .build (pnpm · compose default) + .nx-build (nx)
echo "  [2/4] webapi build Dockerfiles (.build + .nx-build) + generic infra re-sync"
APPDIR="$NA/apps/$SERVICE/mcs-fastify"
sed_df() { sedi -e "s/demo-exm-webapi/${SERVICE}/g" -e "s/gu-example-system/${WS_NAME}/g" -e "s/exm-data/${DATA_PKG}/g" "$1"; }
for variant in Dockerfile.build Dockerfile.nx-build; do
  DF="$APPDIR/$variant"
  DF_TPL="$GEN/script-generator/template/project/webapi/mcs-fastify/$variant"
  if [ -f "$DF" ] && grep -q 'AS build' "$DF"; then
    echo "      ! $variant = multi-stage แล้ว, skip"
  else
    cp "$DF_TPL" "$DF"; sed_df "$DF"; echo "      + $variant (multi-stage)"
  fi
done
# tokenless generic infra (.dockerignore · verify Dockerfiles · tools/ · root .gitattributes/.editorconfig) → force-sync
# แทน guard `[ -f ] ||` เดิม (ที่ cp เฉพาะตอนไม่มี → template ใหม่ไม่ถึง workspace เดิม) · sync-infra เขียนทับให้ตรง template
bash "$SCRIPT_DIR/lib/sync-infra.sh" "$WS_ROOT" --quiet | sed 's/^/      /'
# patch *:backend-libs scripts → --exclude apps (glob **/*api-* จับ webapi app ด้วย → test:backend-libs/verify-nx-backend เผลอรัน app jest ติด coverage gate)
# idempotent · npm pkg set เขียนค่ามาตรฐาน (single-quote = literal glob ไม่ให้ shell expand)
if [ -f "$NA/package.json" ]; then
  ( cd "$NA" \
    && npm pkg set 'scripts.lint:backend-libs=nx run-many --target=lint --projects=**/common-functions*,**/*api-*,**/*-data-store* --exclude=*webapi*,*webpub*,*websub*,*webio*' \
    && npm pkg set 'scripts.test:backend-libs=nx run-many --target=test --projects=**/common-functions*,**/*api-*,**/*-data-store* --exclude=*webapi*,*webpub*,*websub*,*webio*' \
    && npm pkg set 'scripts.build:backend-libs=nx run-many --target=build --projects=**/common-functions*,**/*api-*,**/*-data-store* --exclude=*webapi*,*webpub*,*websub*,*webio*' ) \
    && echo "      + patched *:backend-libs scripts (--exclude apps)"
fi

# ── Step 3: discover domains/actions → contract+test pair (idempotent) ──
echo "  [3/4] backfill contract+test pairs (จาก core domains ที่มี)"
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
echo "  [4/4] wire prisma migrations → changelog (context=migrate)"
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

# NOTE: ไม่ bump template-version ที่นี่ — driver (apply-migration.sh) เขียน = 1.5.0 + log ให้หลัง rung นี้สำเร็จ
echo "=== [migration-v1.5.0] done ==="
echo "  auto: infra + backend-test (pure harness + per-service _config) + webapi Dockerfile.build(pnpm)+.nx-build(nx) + generic infra re-sync (sync-infra: verify Dockerfiles + .dockerignore + tools/ + conventions) + wire migration"
echo "        (runtime-only Dockerfile ของ CI release→docker:build ไม่ถูกแตะ · compose ใช้ Dockerfile.build · verify: make verify-backend)"
echo "  manual ที่เหลือ (dev):"
echo "    (1) cd workspaces/node-app && pnpm install   (store-prisma postinstall → prisma generate)"
echo "    (2) cd workspaces/backend-test && pnpm install"
echo "    (3) แก้ contract envelope (body/headers/auth) + assertDb ให้ตรง action จริง (skeleton → meaningful)"
echo "    (4) เพิ่ม endpoint/action นอกเหนือที่ core มี (ถ้าต้องการ) ด้วย gen:api-action + wire"
echo "    (5) make api-test       (black-box: bring-up สด → node:test → down)"
echo "    (6) make verify-backend (in-container lint+tsc+unit test · ไม่ต้องมี DB · nx variant = make verify-nx-backend)"
echo "  telemetry: compose api ตั้ง OTEL env ให้แล้ว (Console provider พังใน core@0.3.4) · prefix: _config.ts (TARGET.prefix)"
