#!/bin/bash
# Demote a standalone project (<domain>-api package, flat src/*) -> grouped domain (shared-api/src/<domain>-api/*)
# usage: bash demote-api-domain.sh <WORKSPACE> <SCOPE> <PROJECT> <SHARED_API> [GENERATOR_DIR]
#   PROJECT = standalone package folder (เช่น product-api)   SHARED_API = target grouped api (เช่น shared-api)
set -e
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
WORKSPACE=$1; SCOPE=$2; PROJECT=$3; SHARED=$4; GENERATOR_DIR=$5
SYSTEM_DIR='node-app'
for v in WORKSPACE SCOPE PROJECT SHARED; do
  if [ -z "${!v}" ]; then read -rp "$v: " V; eval "$v=\$V"; fi
done
NEW="$PROJECT"                            # domain folder = project name (เช่น product-api)
NA="$WORKSPACE/workspaces/$SYSTEM_DIR"; ROOT="$NA/libs/$SCOPE"
echo "demote '$PROJECT' :  standalone $PROJECT  ->  $SHARED/src/$NEW/* (grouped)"

for layer in core service client; do
  SP="$ROOT/$PROJECT/$layer"; SA="$ROOT/$SHARED/$layer"
  [ -d "$SP/src" ] || { echo "  ! $SP/src not found, skip $layer"; continue; }
  [ -d "$SA" ] || { echo "  ! target $SA not found (สร้าง shared-api base ก่อน)"; exit 1; }
  mkdir -p "$SA/src/$NEW"
  # move standalone src/* -> shared-api src/<domain>-api/*  (ยกเว้น shared)
  for item in "$SP"/src/*; do
    b="$(basename "$item")"
    if [ "$b" = "shared" ]; then
      # shared utils: ใส่ที่ shared-api/src/shared ถ้ายังไม่มี
      if [ ! -d "$SA/src/shared" ]; then cp -r "$item" "$SA/src/shared"; fi
    else
      cp -r "$item" "$SA/src/$NEW/"
    fi
  done
  # relative shared depth +1 (service): ../../../shared -> ../../../../shared
  if [ "$layer" = "service" ]; then
    find "$SA/src/$NEW" -type f -name "*.ts" -print0 | while IFS= read -r -d '' f; do
      sedi "s#\.\./\.\./\.\./shared/#../../../../shared/#g" "$f"
    done
  fi
  # exports: เพิ่ม domain เข้า shared-api package.json
  node -e '
    const fs=require("fs");const f=process.argv[1],d=process.argv[2],layer=process.argv[3];
    const j=JSON.parse(fs.readFileSync(f));j.exports=j.exports||{};
    if(layer!=="client"){
      j.exports[`./${d}/command/*`]={development:`./src/${d}/command/*/index.ts`,import:`./dist/${d}/command/*/index.mjs`,require:`./dist/${d}/command/*/index.js`,types:`./dist/${d}/command/*/index.d.ts`};
      j.exports[`./${d}/query/*`]={development:`./src/${d}/query/*/index.ts`,import:`./dist/${d}/query/*/index.mjs`,require:`./dist/${d}/query/*/index.js`,types:`./dist/${d}/query/*/index.d.ts`};
    }
    if(layer!=="service") j.exports[`./${d}`]={development:`./src/${d}/index.ts`,import:`./dist/${d}/index.mjs`,require:`./dist/${d}/index.js`,types:`./dist/${d}/index.d.ts`};
    fs.writeFileSync(f,JSON.stringify(j,null,2));
  ' "$SA/package.json" "$NEW" "$layer"
  echo "  + $SHARED/src/$NEW/$layer"
done
# core index: เพิ่ม export domain
CIDX="$ROOT/$SHARED/core/src/index.ts"
[ -f "$CIDX" ] && { grep -q "'./$NEW'" "$CIDX" || echo "export * from './$NEW';" >> "$CIDX"; }

# rewrite imports: @ws/<project>-<L>/ -> @ws/<shared>-<L>/<domain>/ ; @ws/<project>-core' -> @ws/<shared>-core/<domain>'
for L in core service client; do
  grep -rl "@$WORKSPACE/$PROJECT-$L/" "$NA" --include="*.ts" 2>/dev/null | while read -r f; do
    sedi "s#@$WORKSPACE/$PROJECT-$L/#@$WORKSPACE/$SHARED-$L/$NEW/#g" "$f"
  done
done
for q in "'" '"'; do
  grep -rl "@$WORKSPACE/$PROJECT-core$q" "$NA" --include="*.ts" 2>/dev/null | while read -r f; do
    sedi "s#@$WORKSPACE/$PROJECT-core$q#@$WORKSPACE/$SHARED-core/$NEW$q#g" "$f"
  done
done
# consumer deps: ลบ @ws/<project>-* เพิ่ม @ws/<shared>-* (core/service ที่จำเป็น)
for d in $(grep -rl "@$WORKSPACE/$SHARED-\(core\|service\|client\)/$NEW" "$NA/apps" "$NA/libs" --include="*.ts" 2>/dev/null | while read -r f; do dd="$(dirname "$f")"; while [ "$dd" != "$NA" ] && [ ! -f "$dd/package.json" ]; do dd="$(dirname "$dd")"; done; echo "$dd"; done | sort -u); do
  node -e '
    const fs=require("fs");const f=process.argv[1],ws=process.argv[2],proj=process.argv[3],shared=process.argv[4];
    const j=JSON.parse(fs.readFileSync(f));j.dependencies=j.dependencies||{};
    for(const L of ["core","service","client"]){ delete j.dependencies[`@${ws}/${proj}-${L}`]; }
    // เพิ่ม shared-api deps ตามที่ import (เดาจาก core/service พื้นฐาน)
    fs.writeFileSync(f,JSON.stringify(j,null,2));
  ' "$d/package.json" "$WORKSPACE" "$PROJECT" "$SHARED"
done
# remove standalone package
rm -rf "$ROOT/$PROJECT"
echo "done: demoted $PROJECT -> $SHARED/$NEW. ตรวจ git diff; เพิ่ม dep @$WORKSPACE/$SHARED-* ใน consumer ถ้ายังไม่มี"
