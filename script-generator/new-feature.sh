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
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME




cp -r $GENERATOR_DIR/script-generator/template/project/features/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/
# Search and replace in all files under features directory
find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i 'text' | 
    cut -d: -f1 | 
    xargs sed -i '' "s/feature-exm/$PROJECT_NAME/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

echo "Replaced 'feature-exm' with '$PROJECT_NAME/' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/"


npm pkg set name=@$WORKSPACE_DIR/$PROJECT_NAME
npm pkg set scripts.fix:lcov="bash ../../tools/fix_lcov_paths.sh ../../coverage/libs/"$PROJECT_NAME



pnpm install
pnpm update -i




