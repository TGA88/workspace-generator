#!/bin/bash

# WORKSPACE_DIR='gu-example-system'
# PROJECT_NAME='feature-example'
WORKSPACE_DIR=$1
PROJECT_NAME=$2
SCOPE_NAME=$3
GENERATOR_DIR=$4
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

# Check if SCOPE_NAME is null
if [ -z "$SCOPE_NAME" ]; then
   SCOPE_NAME='shared-webapi'
   echo "SCOPE_NAME => $SCOPE_NAME"
fi

# Check if PROJECT_NAME is provided
if [ -z "$PROJECT_NAME" ]; then
   echo "Error: PROJECT_NAME is not set"
   exit 1
fi


CUR_PATH=$(pwd)

# สร้าง folder project
# mkdir -p <workspace_dir>/workspaces/<system_name>
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/client'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/client




cp -r $GENERATOR_DIR/script-generator/template/project/api-client/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/client/

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/client
# Search and replace in all files under features directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i '' -e "s/exm-api/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

else

    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
     xargs sed -i -e "s/exm-api/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

fi

echo "Replaced 'exm-api' with '$PROJECT_NAME' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/client/"


npm pkg set name=@$WORKSPACE_DIR/$PROJECT_NAME-client
# npm pkg set scripts.fix:lcov="bash ../../../../tools/fix_lcov_paths.sh ../../../../coverage/libs/$SCOPE_NAME/$PROJECT_NAME/client"

# add inh-lib/common , inh-lib/ddd
# pnpm add -w @inh-lib/common @inh-lib/ddd
# pnpm add -w zod

pnpm install
pnpm update -i





