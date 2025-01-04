#!/bin/bash

# WORKSPACE_DIR='feedos-example-system'
# PROJECT_NAME='feature-example'
WORKSPACE_DIR=$1
PROJECT_NAME=$2
GENERATOR_DIR=$3
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


CUR_PATH=$(pwd)

# สร้าง folder project
# mkdir -p <workspace_dir>/workspaces/<system_name>
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME-data/store-prisma'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME-data/store-prisma




cp -r $GENERATOR_DIR/script-generator/template/project/store-prisma/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME-data/store-prisma/
cp -r $GENERATOR_DIR/script-generator/template/project/store-prisma/.env $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME-data/store-prisma/.env

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME-data/store-prisma

# # ตรวจสอบไฟล์ที่มี EXM
# find . -type f -exec grep -l "EXM" {} \;

# # ตรวจสอบ file type
# find . -type f -exec file {} \;

# Search and replace in all files under features directory

str=$PROJECT_NAME
# แปลงเป็นตัวพิมพ์ใหญ่ก่อน
str=$(echo "$str" | tr '[:lower:]' '[:upper:]')
# แล้วค่อยเปลี่ยน - เป็น _
str=$(echo "$str" | tr '-' '_')
LOWER_PROJECT_NAME=$str


if [[ "$OSTYPE" == "darwin"* ]]; then
    # find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i '' -e "s/exm/$PROJECT_NAME/g" -e "s/EXM/$LOWER_PROJECT_NAME/g" -e "s/feedos-example-system/$WORKSPACE_DIR/g"

else
    # find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i -e "s/exm/$PROJECT_NAME/g" -e "s/EXM/$LOWER_PROJECT_NAME/g" -e "s/feedos-example-system/$WORKSPACE_DIR/g"


fi


    

echo "Replaced 'exm' with '$PROJECT_NAME' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME-data/store-prisma/"


npm pkg set name=@$WORKSPACE_DIR/$PROJECT_NAME-data-store-prisma
npm pkg set scripts.fix:lcov="bash ../../../tools/fix_lcov_paths.sh ../../../coverage/libs/"$PROJECT_NAME-data/store-prisma


pnpm add -w @prisma/client@^5.6.0 prisma@^5.6.0
pnpm install
pnpm update -i





