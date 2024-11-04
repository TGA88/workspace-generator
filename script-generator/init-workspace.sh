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

# overwrite nx config
cd $CUR_PATH
echo "cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/node-app/$SYSTEM_DIR"
cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/node-app/$SYSTEM_DIR