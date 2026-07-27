#!/bin/bash
# generate-exports-web.sh — gen "exports" ของ frontend lib (โครง lib/<sub-module>/main.ts)
#
# ⚠️ แยกจาก generate-exports.sh (backend-only): ตัวนั้น key จาก src/*/index.ts —
# frontend ใช้ main.ts เป็น public surface + source อยู่ lib/ → ห้ามใช้ข้าม convention
# (รันตัว backend ใน frontend lib จะเจอ 0 index.ts แล้วทับ exports เป็นก้อนว่าง)
#
# รูปที่ gen (ตาม developer-handbook export-strategy — dual-condition v1.4):
#   "."          จาก <SOURCE>/main.ts(x)
#   "./<sub>/*"  ต่อ top-level dir ของ <SOURCE> ที่มี main.ts(x) (feature-* / ui-* / functions ...)
# wildcard * ใน subpath pattern match ข้าม "/" ได้ → consumer เจาะรายไฟล์ได้
# เช่น @scope/lib/feature-x/main หรือ @scope/lib/feature-x/pages/login/login.page
set -euo pipefail

SOURCE_PATH=${1:-lib}
ESM_EXT=${2:-js}
CJS_EXT=${3:-cjs}

command -v jq >/dev/null 2>&1 || { echo "Error: jq is not installed (macOS: brew install jq)"; exit 1; }
[ -f package.json ] || { echo "Error: package.json not found (ต้องรันในโฟลเดอร์ของ lib project)"; exit 1; }
[ -d "$SOURCE_PATH" ] || { echo "Error: source dir '$SOURCE_PATH' not found"; exit 1; }

temp_exports=$(mktemp package-temp.XXXXXX)
temp_merged=""
cleanup() { rm -f "$temp_exports" ${temp_merged:+"$temp_merged"}; }
trap cleanup EXIT

first=true
count=0
sep() {
    if [ "$first" = true ]; then first=false; else echo "," >> "$temp_exports"; fi
}

echo '{' > "$temp_exports"
echo '  "exports": {' >> "$temp_exports"

# root "." จาก <SOURCE>/main.ts(x)
if [ -f "$SOURCE_PATH/main.ts" ] || [ -f "$SOURCE_PATH/main.tsx" ]; then
    sep
    cat >> "$temp_exports" <<EOF
    ".": {
      "development": ["./${SOURCE_PATH}/main.tsx", "./${SOURCE_PATH}/main.ts"],
      "types": "./dist/types/main.d.ts",
      "import": "./dist/main.${ESM_EXT}",
      "require": "./dist/main.${CJS_EXT}"
    }
EOF
    count=$((count + 1))
fi

# "./<sub>/*" ต่อ top-level dir ที่มี main.ts(x)
for dir in "$SOURCE_PATH"/*/; do
    [ -d "$dir" ] || continue
    sub=$(basename "$dir")
    if [ -f "${dir}main.ts" ] || [ -f "${dir}main.tsx" ]; then
        sep
        cat >> "$temp_exports" <<EOF
    "./${sub}/*": {
      "development": ["./${SOURCE_PATH}/${sub}/*.tsx", "./${SOURCE_PATH}/${sub}/*.ts"],
      "types": "./dist/types/${sub}/*.d.ts",
      "import": "./dist/${sub}/*.${ESM_EXT}",
      "require": "./dist/${sub}/*.${CJS_EXT}"
    }
EOF
        count=$((count + 1))
    else
        echo "skip: ${sub}/ (ไม่มี main.ts — sub-module ต้องมี main.ts เป็น public surface)"
    fi
done

echo '  }' >> "$temp_exports"
echo '}' >> "$temp_exports"

# guard: gen ได้ 0 entry = ห้ามแตะ package.json (กันทับ exports เดิมด้วยก้อนว่าง)
if [ "$count" -eq 0 ]; then
    echo "Error: ไม่พบ main.ts(x) ใน ${SOURCE_PATH}/ หรือ ${SOURCE_PATH}/*/ — ไม่แตะ package.json"
    echo "(ถ้า lib นี้เป็นโครง backend (src/*/index.ts) → ใช้ generate-exports.sh ตัวเดิม)"
    exit 1
fi

temp_merged=$(mktemp package-new.XXXXXX)
jq -s '.[0] as $original | .[1] as $new | $original + $new' package.json "$temp_exports" > "$temp_merged"
mv "$temp_merged" package.json
temp_merged=""

echo "Successfully updated exports (${count} entries) in package.json"
