#!/bin/bash

# WORKSPACE_DIR='gu-example-system'
# PROJECT_NAME='feature-example'
WORKSPACE_DIR=$1
PROJECT_NAME=$3
SCOPE_NAME=$2
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
   SCOPE_NAME='shared-web'
   echo "SCOPE_NAME => $SCOPE_NAME"
fi

# Check if PROJECT_NAME is provided
if [ -z "$PROJECT_NAME" ]; then
    # PROJECT_NAME='ui-components'
   echo "PROJECT_NAME: $PROJECT_NAME"
fi


CUR_PATH=$(pwd)

# สร้าง folder project
# mkdir -p <workspace_dir>/workspaces/<system_name>
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME




cp -r $GENERATOR_DIR/script-generator/template/project/features/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/
rm  -rf $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/lib/*
touch $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/lib/.gitkeep
touch $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/lib/main.ts


cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME


# # ตำแหน่งปัจจุบัน
# current_dir=$(pwd)
# # ค้นหา nx.json
# search_dir="$current_dir"
# while [[ "$search_dir" != "/" ]]; do
#   if [[ -f "$search_dir/nx.json" ]]; then
#     nx_dir="$search_dir"
#     break
#   fi
#   search_dir=$(dirname "$search_dir")
# done

# if [[ -z "$nx_dir" ]]; then
#   echo "nx.json not found"
#   exit 1
# fi

# # คำนวณ relative path
# relative_path=""
# temp_dir="$current_dir"
# while [[ "$temp_dir" != "$nx_dir" && "$temp_dir" != "/" ]]; do
#   relative_path="../$relative_path"
#   temp_dir=$(dirname "$temp_dir")
# done

# echo "Relative path to nx.json: $relative_path"


# # update extends ใน tsconfig.json
# tsconfig_path="${relative_path}tsconfig.features.base.json"

# # แทนที่ค่า extends ใน tsconfig.json
# sed -i.bak 's|"extends": "[^"]*"|"extends": "'"$tsconfig_path"'"|' tsconfig.json

# echo "Updated extends in tsconfig.json to: $tsconfig_path"

# # update extends ใน tsconfig.json
# eslint_path="${relative_path}root-eslint.config.mjs"

# # แทนที่ค่า extends ใน tsconfig.json
# sed -i.bak 's|"{ createBaseConfig } from ": "[^"]*"|"{ createBaseConfig } from ": "'"$eslint_path"'"|' eslint.config.mjs

# echo "Updated extends in eslint.config.mjs to: $eslint_path"

# # ==========
# # eslint
# relative_path='../../'

# # แทนที่เส้นทางไฟล์ที่อ้างอิงถึง root-eslint.config.mjs
# sed -i.bak "s|\(\.\./\)*root-eslint\.config\.mjs|${relative_path}root-eslint.config.mjs|g" eslint.config.mjs

# echo "Updated all paths to root-eslint.config.mjs with relative_path in eslint.config.mjs"

# # ==========

# # jest
# # แทนที่เส้นทางไฟล์ที่อ้างอิงถึง jest.config.ts
# sed -i.bak "s|\(\.\./\)*jest\.config\.*|${relative_path}jest.config.|g" jest.config.ts

# echo "Updated all paths to jest.config.ts with relative_path in jest.config.ts"



# cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/

# Search and replace in all files under features directory
if [[ -z "$PROJECT_NAME" ]]; then
    echo "set PROJECT_NAME = $SCOPE_NAME"
    PROJECT_NAME=$SCOPE_NAME
fi
if [[ "$OSTYPE" == "darwin"* ]]; then

    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i '' -e "s/feature-exm/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

else
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i -e "s/feature-exm/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

fi


echo "Replaced 'feature-exm' with '$PROJECT_NAME/' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/"

npm pkg set name=@$WORKSPACE_DIR/$PROJECT_NAME

if [[ $PROJECT_NAME == $SCOPE_NAME ]]; then
    echo "set PROJECT_NAME = '' "
    PROJECT_NAME=''
fi
npm pkg set scripts.fix:lcov="bash ../../../tools/fix_lcov_paths.sh ../../../coverage/libs/"$SCOPE_NAME/$PROJECT_NAME

pnpm update:config



pnpm install
pnpm update -i





