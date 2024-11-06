#!/bin/bash

# WORKSPACE_DIR='feedos-example-system'
# SYSTEM_DIR='node-app' [node,springboot,dotnet]
WORKSPACE_DIR=$1
SYSTEM_DIR=$2

CUR_PATH=$(pwd)

echo "cur => $CUR_PATH"
# สร้าง workspace folder folder 
# mkdir -p <workspace_dir>/workspaces/<system_name>
mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/apps

mkdir -p $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/libs


cp script-generator/template/workspace/.gitignore $WORKSPACE_DIR

cp script-generator/template/workspace/pnpm-workspace.yaml $WORKSPACE_DIR/workspaces/$SYSTEM_DIR


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


