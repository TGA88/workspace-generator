#!/bin/bash

# WORKSPACE_DIR='feedos-example-system'
# SYSTEM_DIR='node-app' [node,springboot,dotnet]
WORKSPACE_DIR=$1
SYSTEM_DIR=$2
GENERATOR_DIR=$3



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



CUR_PATH=$(pwd)

echo "cur => $CUR_PATH"
# สร้าง workspace folder folder 
# mkdir -p <workspace_dir>/workspaces/<system_name>
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps

mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs

mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/docs/storybook-host
touch $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/docs/storybook-host/.gitkeep


cp $GENERATOR_DIR/script-generator/template/workspace/.gitignore $WORKSPACE_DIR

cp $GENERATOR_DIR/script-generator/template/workspace/pnpm-workspace.yaml $WORKSPACE_DIR/workspaces/$SYSTEM_DIR


corepack enable pnpm

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm init

npm pkg set name=$WORKSPACE_DIR

# set minimum node version
npm pkg set engines.node=">=20"

# set packageManager ใน package.json file
npm pkg set packageManager="pnpm@9.1.4" 

# upgrade packageManager to latest version
corepack use pnpm@latest

# git init
cd $CUR_PATH
cd $WORKSPACE_DIR
git init

