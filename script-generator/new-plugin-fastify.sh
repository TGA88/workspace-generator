#!/bin/bash

# WORKSPACE_DIR='gu-example-system'
# PROJECT_NAME='feature-example'
WORKSPACE_DIR=$1
SCOPE_NAME=$2
PROJECT_NAME=$3
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


# Check if PROJECT_NAME is provided
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME='api-plugin-fastify'
   echo "PROJECT_NAME: $PROJECT_NAME"
fi


CUR_PATH=$(pwd)

# สร้าง folder project
# mkdir -p <workspace_dir>/workspaces/<system_name>
echo 'mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME'
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME




cp -r $GENERATOR_DIR/script-generator/template/project/api-plugin-fastify/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/
# Search and replace in all files under features directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i '' -e "s/api-plugin-fastify/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

else
    find ./ -type f -not -path "*/\.*" -exec file {} \; | 
    grep -i -E '(text| JSON data)' | 
    cut -d: -f1 | 
    xargs sed -i -e "s/api-plugin-fastify/$PROJECT_NAME/g" -e "s/gu-example-system/$WORKSPACE_DIR/g"
    # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

fi


echo "Replaced 'api-plugin-fastify' with '$PROJECT_NAME/' in all files under $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/"


npm pkg set name=@$WORKSPACE_DIR/$PROJECT_NAME
npm pkg set scripts.fix:lcov="bash ../../tools/fix_lcov_paths.sh ../../coverage/libs/"$PROJECT_NAME
npm pkg set scripts.gen:exports="bash ../../tools/generate-exports.sh src "



pnpm install
pnpm update -i

# Check if SCOPE_NAME isnot null
if [ -n "$SCOPE_NAME" ]; then
    cd $CUR_PATH

    echo $(pwd)

    echo "mkdir -p $WORKSPACE_DIR/workspaces/${SYSTEM_DIR}/libs/${SCOPE_NAME}/${PROJECT_NAME}"
    mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME

    cp -r $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME/

    rm -rf $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$PROJECT_NAME

    cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs/$SCOPE_NAME/$PROJECT_NAME
    npm pkg set scripts.fix:lcov="bash ../../../tools/fix_lcov_paths.sh ../../../coverage/libs/"$SCOPE_NAME/$PROJECT_NAME
    npm pkg set scripts.gen:exports="bash ../../../tools/generate-exports.sh src "

    if [[ "$OSTYPE" == "darwin"* ]]; then
        find ./ -type f -not -path "*/\.*" -exec file {} \; | 
        grep -i -E '(text| JSON data)' | 
        cut -d: -f1 | 
        xargs sed -i '' -e "s/'..\/..\/root-eslint/'..\/..\/..\/root-eslint/g"  -e 's|\.\./\.\./tsconfig-|../../../tsconfig-|g' -e "s/'..\/..\/jest.config/'..\/..\/..\/jest.config/g"  
        # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

        # if it is json file must using below syntax for finding text and replace
        # sed -i '' -e 's|\.\./\.\./tsconfig-|../../../tsconfig-|g' 
    else
        find ./ -type f -not -path "*/\.*" -exec file {} \; | 
        grep -i -E '(text| JSON data)' | 
        cut -d: -f1 | 
        xargs sed -i -e "s/'..\/..\/root-eslint/'..\/..\/..\/root-eslint/g"  -e 's|\.\./\.\./tsconfig-|../../../tsconfig-|g' -e "s/'..\/..\/jest.config/'..\/..\/..\/jest.config/g"  
        # xargs sed -i '' "s/@feature-exm/@$PROJECT_NAME/g"

    fi
fi








       
        