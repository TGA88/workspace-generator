#!/bin/bash

# WORKSPACE_DIR='feedos-example-workspace'
# SYSTEM_DIR='fos-psc-system'
WORKSPACE_DIR=$1
SYSTEM_DIR=$2

CUR_PATH=$(pwd)

echo "cur => $CUR_PATH"

# install Tools
cd $WORKSPACE_DIR/node-app/$SYSTEM_DIR

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
echo "cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/node-app/$SYSTEM_DIR"
cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/node-app/$SYSTEM_DIR
    