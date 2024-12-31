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
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/mcs-fastify'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/mcs-fastify




cp -r $GENERATOR_DIR/script-generator/template/project/webapi/mcs-fastify/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/mcs-fastify/
cp -r $GENERATOR_DIR/script-generator/template/project/webapi/mcs-fastify/.env.example $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/mcs-fastify/.env

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/mcs-fastify
# Search and replace in all files under webapi directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i '' -e "s/demo-exm-webapi/$PROJECT_NAME/g" -e "s/feedos-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

else

    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
     xargs sed -i -e "s/demo-exm-webapi/$PROJECT_NAME/g" -e "s/feedos-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

fi

echo "Replaced 'demo-exm-webapi' with '$PROJECT_NAME' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps/$PROJECT_NAME/mcs-fastify/"


npm pkg set name=$PROJECT_NAME-mcs-fastify
npm pkg set scripts.fix:lcov="bash ../../../tools/fix_lcov_paths.sh ../../../coverage/apps/"$PROJECT_NAME/mcs-fastify

# add inh-lib/common , inh-lib/ddd
pnpm add -w @inh-lib/common @inh-lib/ddd

pnpm install
pnpm update -i





