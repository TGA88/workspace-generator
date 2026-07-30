#!/bin/bash
# new-storybook.sh <workspace-dir> <host-name> [generator-dir] [lib-scope]
#
# WORKSPACE_DIR='gu-example-system'
# PROJECT_NAME='feature-example'
#
# v1.7.1 — LIB_SCOPE ($4) = โฟลเดอร์ใต้ `libs/` ที่ host นี้ครอบ · default = `<host-name>-lib`
#   เดิม scaffold ออก `stories: ['../../../libs/**/…']` = ครอบทุก base ⇒ host ของ base ใหม่
#   เขียวด้วย story ของ base เก่า (false signal ที่ auth-portal เจอที่ P-PW.5d-1)
#   mode อยู่ที่ $4 เหมือน new-web.sh — $3 = GENERATOR_DIR มาแต่เดิม แทรกตรงนั้นพัง caller เก่า
#   libs ของ workspace อยู่ที่อื่น (เช่น default `shared-web` ของ new-frontend-lib-modules.sh)
#   → ส่ง $4 มาเอง เช่น: new-storybook.sh <ws> example "" shared-web
WORKSPACE_DIR=$1
PROJECT_NAME=$2
GENERATOR_DIR=$3
LIB_SCOPE=$4
SYSTEM_DIR='node-app'



if [ -z "$GENERATOR_DIR" ]; then
    echo "ตัวแปร GENERATOR_DIR ไม่มีค่า หรือมีค่าว่าง"
    if [ -d "workspace-generator" ]; then
        echo "มีโฟลเดอร์ workspace-generator"
        GENERATOR_DIR="workspace-generator"
        echo "กำหนด GENERATOR_DIR='workspace-generator' "
    else
        echo "ไม่มีโฟลเดอร์ workspace-generator"
        GENERATOR_DIR="."
        echo "กำหนด GENERATOR_DIR='.' "
    fi
else
  echo "ตัวแปร GENERATOR_DIR มีค่า: $GENERATOR_DIR"
fi

# Check if PROJECT_NAME is provided
if [ -z "$PROJECT_NAME" ]; then
   echo "Error: PROJECT_NAME is not set"
   exit 1
fi

if [ -z "$LIB_SCOPE" ]; then
    LIB_SCOPE="${PROJECT_NAME}-lib"
    echo "LIB_SCOPE ไม่ได้ส่งมา → ใช้ convention: '$LIB_SCOPE'"
fi
echo "storybook host '$PROJECT_NAME' จะครอบ libs/$LIB_SCOPE/ (แก้ได้ที่ .storybook/main.ts — tool อ่าน alias จากตรงนั้น)"
if [ ! -d "$WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$LIB_SCOPE" ]; then
    echo "  หมายเหตุ: ยังไม่มี libs/$LIB_SCOPE (ปกติถ้า scaffold host ก่อน lib) — ที่มีอยู่ตอนนี้:"
    ls -1 "$WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs" 2>/dev/null | sed 's/^/    - /'
fi


CUR_PATH=$(pwd)

# สร้าง folder project
# mkdir -p <workspace_dir>/workspaces/<system_name>
echo "mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/storybook-host/$PROJECT_NAME"
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/storybook-host/$PROJECT_NAME




# ใช้ "/." ไม่ใช่ "/*" — หยิบ dotfiles มาด้วยในรอบเดียว (.storybook ฯลฯ ไม่ต้อง copy แยก)
cp -r $GENERATOR_DIR/script-generator/template/project/storybook-host/. $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/storybook-host/$PROJECT_NAME/

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/storybook-host/$PROJECT_NAME/


npm pkg set name=storybook-host-$PROJECT_NAME

# Search and replace in all files under features directory
# ⚠️ `libs/example-lib` ต้องถูกแทนที่ **ก่อน** `example` ตัวเปล่า (sed ไล่ -e ตามลำดับต่อบรรทัด)
# ไม่งั้น `example-lib` จะกลายเป็น `<host>-lib` ไปก่อน แล้ว $LIB_SCOPE ที่ส่งมาไม่มีผล
if [[ "$OSTYPE" == "darwin"* ]]; then
    # find ./ -type f -not -path "*/\.*" -exec file {} \; |
    find ./ -type f -exec file {} \; |
    grep -i -E '(text| JSON data)' |
    cut -d: -f1 |
    xargs sed -i '' -e "s|libs/example-lib|libs/$LIB_SCOPE|g" -e "s/gu-example-system/$WORKSPACE_DIR/g"  -e "s/example/$PROJECT_NAME/g"

else
    find ./ -type f -exec file {} \; |
    grep -i -E '(text| JSON data)' |
    cut -d: -f1 |
    xargs sed -i -e "s|libs/example-lib|libs/$LIB_SCOPE|g" -e "s/gu-example-system/$WORKSPACE_DIR/g" -e "s/example/$PROJECT_NAME/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

fi

# alias ต้องเขียน **หลัง** sed — tool อ่าน scope จาก `stories` ของ main.ts ที่ถูกแทนที่แล้ว
# (ของเดิมเรียกก่อน sed ⇒ อ่าน glob ต้นแบบที่ยังเป็น 'example' — ตอนนั้นไม่มีผลเพราะ tool สแกน libs/ ทั้งก้อนอยู่แล้ว)
cd "$CUR_PATH"
bash $GENERATOR_DIR/script-generator/update-sb.sh $WORKSPACE_DIR $PROJECT_NAME
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/storybook-host/$PROJECT_NAME/

pnpm install --no-frozen-lockfile
pnpm update -i





