#!/bin/bash

# WORKSPACE_DIR='gu-example-system'
# PROJECT_NAME='feature-example'
WORKSPACE_DIR=$1
PROJECT_NAME=$2
GENERATOR_DIR=$3
# MODE = รูปแบบ deploy ของ Next app: standalone (server) | static (output:'export')
# ⚠️ อยู่ที่ $4 โดยตั้งใจ — $3 เป็น GENERATOR_DIR มาแต่เดิม แทรกตรงนั้นจะพัง caller เก่าทั้งหมด
# default = standalone (คงพฤติกรรมเดิมของ v1.6.x เป๊ะ)
MODE=${4:-standalone}
SYSTEM_DIR='node-app'

if [[ "$MODE" != "standalone" && "$MODE" != "static" ]]; then
    echo "ERROR: mode ต้องเป็น 'standalone' หรือ 'static' (ได้: '$MODE')"
    echo "usage: new-web.sh <workspace-dir> <project-name> [generator-dir] [standalone|static]"
    exit 1
fi
echo "MODE => $MODE"



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


CUR_PATH=$(pwd)

# สร้าง folder project
# mkdir -p <workspace_dir>/workspaces/<system_name>
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/nextjs'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/nextjs




APP_DIR=$WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/nextjs
WEB_TEMPLATE=$GENERATOR_DIR/script-generator/template/project/web

# ใช้ "/." ไม่ใช่ "/*" — glob ไม่หยิบ dotfiles (.gitignore ของ template จะหาย)
cp -r $WEB_TEMPLATE/nextjs/. $APP_DIR/
cp -r $WEB_TEMPLATE/nextjs/.env.example $APP_DIR/.env.development

# ── mode: เลือกชุดไฟล์ให้สอดคล้องกันทั้งชุด ตั้งแต่ตอน gen ──────────────────────────
# mode ไม่ได้เปลี่ยนแค่ next.config.mjs — มันเปลี่ยน layout / i18n / การมี middleware พร้อมกัน
# การทิ้ง next-config-mjs-{static,standalone} ไว้ให้ผู้ใช้ copy เอง = แก้ให้แค่ 1 ใน 4 ไฟล์ที่ต้องเปลี่ยน
if [[ "$MODE" == "static" ]]; then
    echo "mode=static → output:'export' (SPA เสิร์ฟด้วย web server ธรรมดา)"
    cp $APP_DIR/next-config-mjs-static $APP_DIR/next.config.mjs
    # static export ไม่มี server runtime → middleware ไม่ถูกเรียก (next build จะเตือน/พัง)
    rm -f $APP_DIR/middleware.ts
    # layout + i18n + messages ฉบับ static (ไม่มี getMessages()/cookies()/requestLocale ที่พึ่ง request)
    cp -r $WEB_TEMPLATE/nextjs-static-overlay/. $APP_DIR/
else
    echo "mode=standalone → output:'standalone' (Next server)"
    cp $APP_DIR/next-config-mjs-standalone $APP_DIR/next.config.mjs
fi
# ต้นฉบับทั้งสองแบบไม่ต้องติดไปกับโปรเจกต์ที่ gen แล้ว (เลือกไปแล้วตั้งแต่บรรทัดบน)
rm -f $APP_DIR/next-config-mjs-static $APP_DIR/next-config-mjs-standalone

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/nextjs
# Search and replace in all files under web directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i '' -e "s/demo-exm-web/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

else

    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
     xargs sed -i -e "s/demo-exm-web/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

fi

echo "Replaced 'demo-exm-web' with '$PROJECT_NAME' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/nextjs/"


npm pkg set name=$PROJECT_NAME-nextjs
npm pkg set scripts.fix:lcov="bash ../../../tools/fix_lcov_paths.sh ../../../coverage/apps/"$PROJECT_NAME/nextjs

# add inh-lib/common , inh-lib/ddd
# pnpm add -w @inh-lib/common @inh-lib/ddd

pnpm install --no-frozen-lockfile
pnpm update -i





