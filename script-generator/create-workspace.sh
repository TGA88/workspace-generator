#!/bin/bash

# WORKSPACE_DIR='feedos-example-workspace'
# SYSTEM_DIR='fos-psc-system'
WORKSPACE_DIR=$1
SYSTEM_DIR=$2

CUR_PATH=$(pwd)

echo "cur => $CUR_PATH"
# สร้าง workspace folder folder 
# mkdir -p <workspace_dir>/node-app/<system_name>
mkdir -p $WORKSPACE_DIR/node-app/$SYSTEM_DIR

mkdir -p $WORKSPACE_DIR/node-app/$SYSTEM_DIR/apps

mkdir -p $WORKSPACE_DIR/node-app/$SYSTEM_DIR/libs


cp script-generator/template/workspace/.gitignore $WORKSPACE_DIR

cp script-generator/template/workspace/pnpm-workspace.yaml $WORKSPACE_DIR/node-app/$SYSTEM_DIR


corepack enable pnpm

cd $WORKSPACE_DIR/node-app/$SYSTEM_DIR

pnpm init

# set minimum node version
npm pkg set engines.node=">=20"

# set packageManager ใน package.json file
npm pkg set packageManager="pnpm@9.1.4" 

# upgrade packageManager to latest version
corepack use pnpm@latest


