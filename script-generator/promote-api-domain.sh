#!/bin/bash
# Promote a grouped domain (shared-api/src/<domain>-api/*) -> standalone project (<domain>-api package, flat src/*)
# usage: bash promote-api-domain.sh <WORKSPACE> <SCOPE> <SHARED_API> <DOMAIN> [GENERATOR_DIR]
#   SHARED_API = grouped api package (เช่น shared-api)   DOMAIN = เช่น product (-> domain folder product-api)
set -e
# portable in-place sed
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
WORKSPACE=$1; SCOPE=$2; SHARED=$3; DOMAIN=$4; GENERATOR_DIR=$5
SYSTEM_DIR='node-app'
for v in WORKSPACE SCOPE SHARED DOMAIN; do
  if [ -z "${!v}" ]; then read -rp "$v: " V; eval "$v=\$V"; fi
done
NEW="${DOMAIN}-api"                       # standalone project folder/name
NA="$WORKSPACE/workspaces/$SYSTEM_DIR"
ROOT="$NA/libs/$SCOPE"
echo "promote '$NEW' :  $SHARED/src/$NEW/*  ->  standalone package $NEW (flat src/*)"

for layer in core service client; do
  SA="$ROOT/$SHARED/$layer"; NP="$ROOT/$NEW/$layer"
  [ -d "$SA/src/$NEW" ] || { echo "  ! $SA/src/$NEW not found, skip $layer"; continue; }
  mkdir -p "$NP/src"
  # 1) copy config files (เอา config ของ shared-api layer มาใช้ — ถูกต้อง+ติดตั้งแล้ว)
  for cfg in tsconfig.json tsconfig.build.json jest.config.ts eslint.config.mjs tsup.config.ts package.json; do
    [ -f "$SA/$cfg" ] && cp "$SA/$cfg" "$NP/$cfg"
  done
  # 2) move domain src (flatten 1 level): src/<domain>-api/* -> src/*
  cp -r "$SA/src/$NEW/." "$NP/src/"
  # 3) service: ต้องมี shared utils ด้วย
  if [ "$layer" = "service" ] && [ -d "$SA/src/shared" ]; then cp -r "$SA/src/shared" "$NP/src/shared"; fi
  # 4) core: src/index.ts ของ standalone ให้ export registry (ของเดิม index.ts ใน domain ก็ทำอยู่แล้ว -> ถูกย้ายมาเป็น src/index.ts)
  # 5) fix package.json: name + exports(flatten) + deps + fix:lcov
  node -e '
    const fs=require("fs");const f=process.argv[1],ws=process.argv[2],neu=process.argv[3],layer=process.argv[4],scope=process.argv[5],shared=process.argv[6];
    const j=JSON.parse(fs.readFileSync(f));
    j.name=`@${ws}/${neu}-${layer}`;
    const ex={};
    ex["."]={development:"./src/index.ts",import:"./dist/index.mjs",require:"./dist/index.js",types:"./dist/index.d.ts"};
    ex["./command/*"]={development:"./src/command/*/index.ts",import:"./dist/command/*/index.mjs",require:"./dist/command/*/index.js",types:"./dist/command/*/index.d.ts"};
    ex["./query/*"]={development:"./src/query/*/index.ts",import:"./dist/query/*/index.mjs",require:"./dist/query/*/index.js",types:"./dist/query/*/index.d.ts"};
    if(layer==="service") ex["./shared/*"]={development:"./src/shared/*",import:"./dist/shared/*.mjs",require:"./dist/shared/*.js",types:"./dist/shared/*.d.ts"};
    if(layer==="client") ex["./types"]={development:"./src/types.ts",import:"./dist/types.mjs",require:"./dist/types.js",types:"./dist/types.d.ts"};
    j.exports=ex;
    if(j.dependencies && j.dependencies[`@${ws}/${shared}-core`]){ delete j.dependencies[`@${ws}/${shared}-core`]; j.dependencies[`@${ws}/${neu}-core`]="workspace:^"; }
    if(j.scripts && j.scripts["fix:lcov"]) j.scripts["fix:lcov"]=j.scripts["fix:lcov"].replace(`/${shared}/${layer}`,`/${neu}/${layer}`);
    fs.writeFileSync(f,JSON.stringify(j,null,2));
  ' "$NP/package.json" "$WORKSPACE" "$NEW" "$layer" "$SCOPE" "$SHARED"
  # 6) relative shared depth -1 (service moved files): ../../../../shared -> ../../../shared
  if [ "$layer" = "service" ]; then
    find "$NP/src" -path "*/shared/*" -prune -o -type f -name "*.ts" -print0 | while IFS= read -r -d '' f; do
      sedi "s#\.\./\.\./\.\./\.\./shared/#../../../shared/#g" "$f"
    done
  fi
  echo "  + standalone $NEW/$layer"
done

# 7) remove domain from shared-api (src + exports + core index)
for layer in core service client; do
  SA="$ROOT/$SHARED/$layer"; [ -d "$SA/src/$NEW" ] && rm -rf "$SA/src/$NEW"
  [ -f "$SA/package.json" ] && node -e '
    const fs=require("fs");const f=process.argv[1],neu=process.argv[2];const j=JSON.parse(fs.readFileSync(f));
    for(const k of Object.keys(j.exports||{})) if(k.includes(`./${neu}/`)||k===`./${neu}`) delete j.exports[k];
    fs.writeFileSync(f,JSON.stringify(j,null,2));' "$SA/package.json" "$NEW"
done
for layer in core service client; do
  IDX="$ROOT/$SHARED/$layer/src/index.ts"
  [ -f "$IDX" ] && sedi "\#'\./$NEW#d" "$IDX"
done

# 8) rewrite consumer imports across whole node-app: @ws/<shared>-<L>/<domain>-api/ -> @ws/<domain>-api-<L>/
for L in core service client; do
  grep -rl "@$WORKSPACE/$SHARED-$L/$NEW/" "$NA" --include="*.ts" 2>/dev/null | while read -r f; do
    sedi "s#@$WORKSPACE/$SHARED-$L/$NEW/#@$WORKSPACE/$NEW-$L/#g" "$f"
  done
done
# 8b) domain-index/registry import (subpath ลงท้ายด้วย quote): @ws/<shared>-core/<domain>' -> @ws/<domain>-core'
for q in "'" '"'; do
  grep -rl "@$WORKSPACE/$SHARED-core/$NEW$q" "$NA" --include="*.ts" 2>/dev/null | while read -r f; do
    sedi "s#@$WORKSPACE/$SHARED-core/$NEW$q#@$WORKSPACE/$NEW-core$q#g" "$f"
  done
done
echo "rewrote consumer imports (@$WORKSPACE/$SHARED-*/$NEW/ -> @$WORKSPACE/$NEW-*/)"
# 8c) auto-add workspace dep ให้ consumer ที่ import standalone package
for L in core service client; do
  grep -rl "@$WORKSPACE/$NEW-$L/" "$NA/apps" "$NA/libs" --include="*.ts" 2>/dev/null | while read -r f; do
    d="$(dirname "$f")"
    while [ "$d" != "$NA" ] && [ ! -f "$d/package.json" ]; do d="$(dirname "$d")"; done
    [ -f "$d/package.json" ] || continue
    case "$d" in *"/$NEW/"*) continue;; esac
    node -e 'const fs=require("fs");const f=process.argv[1],dep=process.argv[2];const j=JSON.parse(fs.readFileSync(f));j.dependencies=j.dependencies||{};if(!j.dependencies[dep]){j.dependencies[dep]="workspace:^";fs.writeFileSync(f,JSON.stringify(j,null,2));}' "$d/package.json" "@$WORKSPACE/$NEW-$L" 2>/dev/null || true
  done
done
echo "auto-added @$WORKSPACE/$NEW-* deps to consumers"
# manual note: ถ้า shared-api client มี root aggregate (เช่น DemoShopApiClient) ที่รวม client ของ domain นี้ ต้องแก้เอง
if grep -rq "${DOMAIN}\|$(echo "$DOMAIN" | awk -F- '"'"'{r="";for(i=1;i<=NF;i++)r=r toupper(substr($i,1,1)) substr($i,2);print r}'"'"')Client" "$ROOT/$SHARED/client/src/client.ts" 2>/dev/null; then
  echo "  ⚠ ตรวจ $SHARED/client/src/client.ts (root aggregate) — มี ref ของ ${DOMAIN}; ถ้า aggregate domain นี้ ให้ย้าย/ลบเอง (custom code)"
fi
echo "done: promoted $NEW. ตรวจ git diff. (deps + import แก้อัตโนมัติแล้ว)"
