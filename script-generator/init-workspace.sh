#!/bin/bash

# WORKSPACE_DIR='feedos-example-system'
# SYSTEM_DIR='node-app'
WORKSPACE_DIR=$1
SYSTEM_DIR=$2

CUR_PATH=$(pwd)

echo "cur => $CUR_PATH"

# install Tools
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# ติดตั้ง NX ที่ระดับ Project
pnpm install nx -D -w

# initial nx เพื่อ สร้าง config file nx.json
pnpx nx@latest init


# set nx command
npm pkg delete scripts.test

npm pkg set scripts.lint="nx lint"
npm pkg set scripts.lint:all="nx run-many --target=lint --all"
npm pkg set scripts.test="nx test"
npm pkg set scripts.test:all="nx run-many --target=test --all"
npm pkg set scripts.build="nx build"
npm pkg set scripts.build:all="nx run-many --target=build --all"
npm pkg set scripts.release="nx run-many --target=build --all"
npm pkg set scripts.release:all="nx run-many --target=release --all && nx run-many --target=release-storybook --all"

# overwrite nx config
cd $CUR_PATH
echo "cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# install committizen
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add git-cz -w -D

npm pkg set scripts.commit="git-cz"

cd $CUR_PATH
echo "cp script-generator/template/workspace/changelog.config.js $CUR_PATH"
cp script-generator/template/workspace/changelog.config.js $CUR_PATH

# install typescript
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add -Dw typescript
cd $CUR_PATH
echo "cp script-generator/template/workspace/system-workspace/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp script-generator/template/workspace/system-workspace/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR




    