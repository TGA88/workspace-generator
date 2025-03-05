#!/bin/bash

# WORKSPACE_DIR='gu-example-system'
# SYSTEM_DIR='node-app'
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

# move to workspace
echo "cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# Get package information from package.json
PACKAGE_NAME=$(node -p "require('./package.json').name")
PACKAGE_VERSION=$(node -p "require('./package.json').version")
PACKAGE_DESC=$(node -p "require('./package.json').description")

echo "Package name: $PACKAGE_NAME"
echo "Version: $PACKAGE_VERSION"
echo "Description: $PACKAGE_DESC"

# update command script
# npm pkg delete scripts.test

# npm pkg set scripts.lint="nx lint"
# npm pkg set scripts.lint:all="nx run-many --target=lint --all"
# npm pkg set scripts.lint:apps="nx run-many --target=lint --projects=*web*"
# npm pkg set scripts.lint:frontend-apps="nx run-many --target=lint --projects=*web-*"
# npm pkg set scripts.lint:backend-apps="nx run-many --target=lint --projects=*webapi*,*webpub*,*websub*,*webio*"
# npm pkg set scripts.lint:libs="nx run-many --target=lint --projects=@${WORKSPACE_DIR}/*"
# npm pkg set scripts.lint:frontend-libs="nx run-many --target=lint --projects=*/ui*,*/feature*,**/common-functions"
# npm pkg set scripts.lint:backend-libs="nx run-many --target=lint --projects=**/common-functions*,**/*api-*,**/*-data-store*"
# npm pkg set scripts.test="nx test"
# npm pkg set scripts.test:all="nx run-many --target=test --all"
# npm pkg set scripts.test:apps="nx run-many --target=test --projects=*web*"
# npm pkg set scripts.test:frontend-apps="nx run-many --target=test --projects=*web-*"
# npm pkg set scripts.test:backend-apps="nx run-many --target=test --projects=*webapi*,*webpub*,*websub*,*webio*"
# npm pkg set scripts.test:libs="nx run-many --target=build --projects=@${WORKSPACE_DIR}/*"
# npm pkg set scripts.test:frontend-libs="nx run-many --target=test --projects=*/ui*,*/feature*,**/common-functions"
# npm pkg set scripts.test:backend-libs="nx run-many --target=test --projects=**/common-functions*,**/*api-*,**/*-data-store*"
# npm pkg set scripts.build="nx build"
# npm pkg set scripts.build:all="nx run-many --target=build --all"
# npm pkg set scripts.release="nx run-many --target=build --all"
# npm pkg set scripts.release:all="nx run-many --target=release --all && nx run-many --target=release-storybook --all"
# npm pkg set scripts.build:apps="nx run-many --target=build --projects=*web*"
# npm pkg set scripts.build:frontend-apps="nx run-many --target=build --projects=*web-*"
# npm pkg set scripts.build:backend-apps="nx run-many --target=build --projects=*webapi*,*webpub*,*websub*,*webio*"
# npm pkg set scripts.build:libs="nx run-many --target=build --projects=@${WORKSPACE_DIR}/*"
# npm pkg set scripts.build:frontend-libs="nx run-many --target=build --projects=*/ui*,*/feature*,**/common-functions"
# npm pkg set scripts.build:backend-libs="nx run-many --target=build --projects=**/common-functions*,**/*api-*,**/*-data-store*"
# npm pkg set scripts.build:features="nx run-many --target=build --projects=*/feature*"
# npm pkg set scripts.build:ui="nx run-many --target=build --projects=*/ui*"
# npm pkg set scripts.build:api="nx run-many --target=build --projects=**/*api-*"
# npm pkg set scripts.build:store="nx run-many --target=build --projects=**/*-data-store*"
# npm pkg set scripts.build:functions="nx run-many --target=build --projects=**/*-functions*"
# npm pkg set scripts.build:others="nx run-many --target=build --projects=**/*plugin*"
# npm pkg set scripts.show:graph="nx graph"

cd $CUR_PATH

#update package.json at workspace
echo "update package.json at workspace"
echo "cp $GENERATOR_DIR/script-generator/template/workspace/package.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/"
cp $GENERATOR_DIR/script-generator/template/workspace/package.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/

# Update package name, version, and description
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
echo 'npm pkg set name="${PACKAGE_NAME}"'
npm pkg set name="${PACKAGE_NAME}"

echo 'npm pkg set version="${PACKAGE_VERSION}"'
npm pkg set version="${PACKAGE_VERSION}"

echo 'npm pkg set description="${PACKAGE_DESC}"'
npm pkg set description="${PACKAGE_DESC}"
cd $CUR_PATH

# overwrite nx config
echo "update nx config"
echo "cp $GENERATOR_DIR/script-generator/template/workspace/nx.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/nx.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# overwrite nxignore config
echo "update nxignore config"
cd $CUR_PATH
echo "cp $GENERATOR_DIR/script-generator/template/workspace/.nxignore $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/.nxignore $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# update git-cz config
echo "update git-cz config"
echo "cp $GENERATOR_DIR/script-generator/template/workspace/changelog.config.js $WORKSPACE_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/changelog.config.js $WORKSPACE_DIR
# ==================

# update tsconfig
echo "update tsconfig"
echo "cp $GENERATOR_DIR/script-generator/template/workspace/tsconfig.base.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/tsconfig.base.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
# ==========

# update tsconfig-base-config (root-tailwind,postcss,build-script,tsconfig base)
echo "update root-config"
echo "cp -r $GENERATOR_DIR/script-generator/template/workspace/system-workspace/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp -r $GENERATOR_DIR/script-generator/template/workspace/system-workspace/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
# =================

# update tsup.lib.config.ts
echo "update tsup.lib.config.ts"
echo "cp $GENERATOR_DIR/script-generator/template/workspace/tsup.lib.config.ts $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/tsup.lib.config.ts $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

#=======

# update jest and lint config

 echo "update prettierrc"
 cp $GENERATOR_DIR/script-generator/template/project/.prettierignore $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp $GENERATOR_DIR/script-generator/template/project/.prettierrc $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

 echo "update root-eslint"
 cp $GENERATOR_DIR/script-generator/template/project/root-eslint.config.mjs $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

 echo "update jest base config"
 cp -r $GENERATOR_DIR/script-generator/template/project/jest.config* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/
# ===============

# update tools
echo "update tools"
echo "cp -r $GENERATOR_DIR/script-generator/template/workspace/tools $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp -r $GENERATOR_DIR/script-generator/template/workspace/tools $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
#================================================================================================

    