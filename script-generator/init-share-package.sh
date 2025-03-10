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

# install Tools
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# ติดตั้ง NX ที่ระดับ Project
pnpm add nx@^20.4.6 -D -w

# initial nx เพื่อ สร้าง config file nx.json
pnpx nx@^20.4.6 init


# set nx command
npm pkg delete scripts.test


npm pkg set scripts.lint="nx lint"
npm pkg set scripts.lint:all="nx run-many --target=lint --all"
npm pkg set scripts.lint:apps="nx run-many --target=lint --projects=*web*"
npm pkg set scripts.lint:frontend-apps="nx run-many --target=lint --projects=*web-*"
npm pkg set scripts.lint:backend-apps="nx run-many --target=lint --projects=*webapi*,*webpub*,*websub*,*webio*"
npm pkg set scripts.lint:libs="nx run-many --target=lint --projects=@${WORKSPACE_DIR}/*"
npm pkg set scripts.lint:frontend-libs="nx run-many --target=lint --projects=*/ui*,*/feature*,**/common-functions,@${WORKSPACE_DIR}/*-lib"
npm pkg set scripts.lint:backend-libs="nx run-many --target=lint --projects=**/common-functions*,**/*api-*,**/*-data-store*"
npm pkg set scripts.test="nx test"
npm pkg set scripts.test:all="nx run-many --target=test --all"
npm pkg set scripts.test:apps="nx run-many --target=test --projects=*web*"
npm pkg set scripts.test:frontend-apps="nx run-many --target=test --projects=*web-*"
npm pkg set scripts.test:backend-apps="nx run-many --target=test --projects=*webapi*,*webpub*,*websub*,*webio*"
npm pkg set scripts.test:libs="nx run-many --target=build --projects=@${WORKSPACE_DIR}/*"
npm pkg set scripts.test:frontend-libs="nx run-many --target=test --projects=*/ui*,*/feature*,**/common-functions,@${WORKSPACE_DIR}/*-lib"
npm pkg set scripts.test:backend-libs="nx run-many --target=test --projects=**/common-functions*,**/*api-*,**/*-data-store*"
npm pkg set scripts.build="nx build"
npm pkg set scripts.build:all="nx run-many --target=build --all"
npm pkg set scripts.release="nx run-many --target=build --all"
npm pkg set scripts.release:all="nx run-many --target=release --all && nx run-many --target=release-storybook --all"
npm pkg set scripts.build:apps="nx run-many --target=build --projects=*web*"
npm pkg set scripts.build:frontend-apps="nx run-many --target=build --projects=*web-*"
npm pkg set scripts.build:backend-apps="nx run-many --target=build --projects=*webapi*,*webpub*,*websub*,*webio*"
npm pkg set scripts.build:libs="nx run-many --target=build --projects=@${WORKSPACE_DIR}/*"
npm pkg set scripts.build:frontend-libs="nx run-many --target=build --projects=*/ui*,*/feature*,**/common-functions,@${WORKSPACE_DIR}/*-lib"
npm pkg set scripts.build:backend-libs="nx run-many --target=build --projects=**/common-functions*,**/*api-*,**/*-data-store*"
npm pkg set scripts.build:features="nx run-many --target=build --projects=*/feature*"
npm pkg set scripts.build:ui="nx run-many --target=build --projects=*/ui*"
npm pkg set scripts.build:api="nx run-many --target=build --projects=**/*api-*"
npm pkg set scripts.build:store="nx run-many --target=build --projects=**/*-data-store*"
npm pkg set scripts.build:functions="nx run-many --target=build --projects=**/*-functions*"
npm pkg set scripts.build:others="nx run-many --target=build --projects=**/*plugin*"
npm pkg set scripts.show:graph="nx graph"

# overwrite nx config
cd $CUR_PATH
echo "$GENERATOR_DIR/cp script-generator/template/workspace/nx.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/nx.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# install committizen
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add git-cz@^4.9.0 -w -D

npm pkg set scripts.commit="git-cz"

pnpm add -w -D @changesets/cli@^2.27.5

cd $CUR_PATH
echo "cp $GENERATOR_DIR/script-generator/template/workspace/changelog.config.js $WORKSPACE_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/changelog.config.js $WORKSPACE_DIR
# ==================

# install typescript
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add -Dw typescript@~5.4.2
cd $CUR_PATH
echo "cp $GENERATOR_DIR/script-generator/template/workspace/tsconfig.base.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/tsconfig.base.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
# ==========

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# install tailwind
pnpm add -Dw tailwindcss@^3.4.17 postcss@^8.5.1 autoprefixer@10.4.20

# ===========

# add mui

# pnpm add -w @mui/material @emotion/react @emotion/styled @mui/icons-material @mui/x-data-grid

# ===========

# copy root-config
cd $CUR_PATH
echo "cp -r $GENERATOR_DIR/script-generator/template/workspace/system-workspace/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp -r $GENERATOR_DIR/script-generator/template/workspace/system-workspace/* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
# =================

# install tsup

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add -Dw tsup@^6.6.0
cd $CUR_PATH
echo "cp $GENERATOR_DIR/script-generator/template/workspace/tsup.lib.config.ts $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/tsup.lib.config.ts $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

#=======

# install dev tools
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 
 # install npm-run-all สำหรับ run script หลายๆ script พร้อมๆกัน เอาไว้แก้ปัญหา hotReload ของ project fastify webapi
pnpm add -Dw npm-run-all@^4.1.5

#install @types/node
pnpm add -Dw @types/node@^22.10.7

# install type สำหรับ sub project type  ui-component และ features
pnpm add -Dw @types/react@^18.3.12 @types/react-dom@^18.3.1

#install jest
pnpm add -Dw jest@^29.7.0 @types/jest@^29.5.14 ts-jest@^29.2.5 jest-config@^29.7.0
# jest ต้องการใช้ ts-node ในการรัน ts
pnpm add -Dw ts-node@^10.9.2


# intall testing tools สำหรับ Next.js หรือ feature project ที่ต้องใช้ renderHooks เพื่อ Test CustomHooks
pnpm add -Dw jest-environment-jsdom@^29.7.0 @testing-library/react@^16.2.0 @testing-library/jest-dom@^6.6.3 @testing-library/user-event@^14.6.0 identity-obj-proxy@^3.0.0


#install prettier
pnpm add -Dw prettier@^3.4.2
npm pkg set scripts.format:all="nx run-many --target=format --all"
npm pkg set scripts.format-check:all="nx run-many --target=format-check --all"

# install eslint
pnpm add -Dw eslint@^9.18.0  @eslint-community/eslint-plugin-eslint-comments@^4.4.1

# globals เอาไว้ใช้ set environment ใน eslint เพื่อให้รู้ว่า จะต้อง ignore keyword document,localstorage เมื่อ set environment เป็น globals.browser เป็นต้น
pnpm add -Dw globals@^15.14.0

#=========

# config eslint for typescript
pnpm add -Dw @typescript-eslint/parser@^8.20.0 @typescript-eslint/eslint-plugin@^8.20.0 @eslint/js@^9.18.0

# config plugin สำหรับ react,nextjs ถ้าใน workspace มี project type ใช้  nextjs,react หลายๆProject
pnpm add -Dw @next/eslint-plugin-next@^15.1.5 eslint-plugin-react@^7.37.4 eslint-plugin-react-hooks@^5.1.0

# config eslint for jest เพื่อให้ ทุก project type สามารถใช้ jest ได้
pnpm add -Dw eslint-plugin-jest@^28.11.0

# config prittier ให้ใช้งานให่้ กับ eslint
pnpm add -Dw  eslint-config-prettier@^10.0.1 

cd $CUR_PATH

# create config file jest,eslint
 cp $GENERATOR_DIR/script-generator/template/project/.prettierignore $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp $GENERATOR_DIR/script-generator/template/project/.prettierrc $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp $GENERATOR_DIR/script-generator/template/project/root-eslint.config.mjs $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp -r $GENERATOR_DIR/script-generator/template/project/jest.config* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/

# ===============

# install vite และ plugin  สำหรับ sub project type ui,features
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add -Dw vite@^6.0.7 @vitejs/plugin-react@^4.3.4 vite-plugin-dts@^4.5.0 vite-plugin-lib-inject-css@^2.2.1 vite-plugin-sass-dts@^1.3.30 vite-plugin-environment@ ^1.1.3

# install Rollup Plugin 
# rollup-plugin-node-externals  สำหรับ unbundle dependency ใน package.json
# rollup-plugin-preserve-directives เพื่อให้ ไม่ถูก remove comment 'use client' หลังจาก bunble
pnpm add -Dw rollup@^4.31.0 rollup-plugin-node-externals@^8.0.0 rollup-plugin-preserve-directives@^0.4.0

# instll glob สำหรับใช้ ในการ config vite ใน sub project type ui,features
pnpm add -Dw glob@^11.0.1
#=====

# install msw สำหรับ ใช้ mock httpClient ของ project type featues ,web หรือ service
pnpm add -Dw msw@^2.7.0 
# ใช้ jest-fixed-jsdom แทน jest-environment-jsdom เพื่อ แก้ปัญหา msw v2 Error Request/Response/TextEncoder is not defined (Jest)
pnpm add -Dw jest-fixed-jsdom@^0.0.9
#======

# install storybook
# ติดตั้ง dependencies ที่ root
pnpm add -Dw storybook@^8.0.0 @storybook/addon-essentials@^8.5.0 @storybook/addon-interactions@^8.5.0 @storybook/addon-links@^8.5.0 @storybook/blocks@^8.5.0 @storybook/react@^8.5.0 @storybook/react-vite@^8.5.0 @storybook/test@^8.5.0 msw-storybook-addon@^2.0.4
# pnpm add -Dw storybook@^8.0.0 @storybook/cli @storybook/addon-essentials @storybook/addon-interactions @storybook/addon-links @storybook/blocks @storybook/react @storybook/react-vite @storybook/test @storybook/testing-library msw-storybook-addon
# =========

pnpm update -i

# # ติดตั้ง dependencies เพิ่มเติมสำหรับ development
# pnpm add -D vite @vitejs/plugin-react autoprefixer postcss tailwindcss storybook-dark-mode @storybook/addon-styling @storybook/addon-a11y chromatic
# #=====



    