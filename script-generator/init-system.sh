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
pnpm install nx -D -w

# initial nx เพื่อ สร้าง config file nx.json
pnpx nx@latest init


# set nx command
npm pkg delete scripts.test


npm pkg set scripts.lint="nx lint"
npm pkg set scripts.lint:all="nx run-many --target=lint --all"
npm pkg set scripts.lint:apps="nx run-many --target=lint --projects=*web*"
npm pkg set scripts.lint:frontend-apps="nx run-many --target=lint --projects=*web-*"
npm pkg set scripts.lint:backend-apps="nx run-many --target=lint --projects=*webapi*,*webpub*,*websub*,*webio*"
npm pkg set scripts.lint:libs="nx run-many --target=lint --projects=@${WORKSPACE_DIR}/*"
npm pkg set scripts.lint:frontend-libs="nx run-many --target=lint --projects=*/ui*,*/feature*,**/common-functions"
npm pkg set scripts.lint:backend-libs="nx run-many --target=lint --projects=**/common-functions*,**/*api-*,**/*-data-store*"
npm pkg set scripts.test="nx test"
npm pkg set scripts.test:all="nx run-many --target=test --all"
npm pkg set scripts.test:apps="nx run-many --target=test --projects=*web*"
npm pkg set scripts.test:frontend-apps="nx run-many --target=test --projects=*web-*"
npm pkg set scripts.test:backend-apps="nx run-many --target=test --projects=*webapi*,*webpub*,*websub*,*webio*"
npm pkg set scripts.test:libs="nx run-many --target=build --projects=@${WORKSPACE_DIR}/*"
npm pkg set scripts.test:frontend-libs="nx run-many --target=test --projects=*/ui*,*/feature*,**/common-functions"
npm pkg set scripts.test:backend-libs="nx run-many --target=test --projects=**/common-functions*,**/*api-*,**/*-data-store*"
npm pkg set scripts.build="nx build"
npm pkg set scripts.build:all="nx run-many --target=build --all"
npm pkg set scripts.release="nx run-many --target=build --all"
npm pkg set scripts.release:all="nx run-many --target=release --all && nx run-many --target=release-storybook --all"
npm pkg set scripts.build:apps="nx run-many --target=build --projects=*web*"
npm pkg set scripts.build:frontend-apps="nx run-many --target=build --projects=*web-*"
npm pkg set scripts.build:backend-apps="nx run-many --target=build --projects=*webapi*,*webpub*,*websub*,*webio*"
npm pkg set scripts.build:libs="nx run-many --target=build --projects=@${WORKSPACE_DIR}/*"
npm pkg set scripts.build:frontend-libs="nx run-many --target=build --projects=*/ui*,*/feature*,**/common-functions"
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

pnpm add git-cz -w -D

npm pkg set scripts.commit="git-cz"

pnpm add -w -D @changesets/cli@^2.27.5

cd $CUR_PATH
echo "cp $GENERATOR_DIR/script-generator/template/workspace/changelog.config.js $WORKSPACE_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/changelog.config.js $WORKSPACE_DIR
# ==================

# install typescript
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add -Dw typescript
cd $CUR_PATH
echo "cp $GENERATOR_DIR/script-generator/template/workspace/tsconfig.base.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
cp $GENERATOR_DIR/script-generator/template/workspace/tsconfig.base.json $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
# ==========

cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

# install tailwind
pnpm add -Dw tailwindcss postcss autoprefixer

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

#install @types/node
pnpm add -Dw @types/node


# install npm-run-all สำหรับ run script หลายๆ script พร้อมๆกัน เอาไว้แก้ปัญหา hotReload ของ project fastify webapi
pnpm add -Dw npm-run-all@^4.1.5

# install type สำหรับ sub project type  ui-component และ features
pnpm add -Dw @types/react@^18.3.12 @types/react-dom@^18.3.1

#install jest
pnpm add -Dw jest @types/jest ts-jest jest-config
# jest ต้องการใช้ ts-node ในการรัน ts
pnpm add -Dw ts-node


# intall testing tools สำหรับ Next.js หรือ feature project ที่ต้องใช้ renderHooks เพื่อ Test CustomHooks
pnpm add -Dw jest-environment-jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event identity-obj-proxy


#install prettier
pnpm add -Dw prettier 
npm pkg set scripts.format:all="nx run-many --target=format --all"
npm pkg set scripts.format-check:all="nx run-many --target=format-check --all"

# install eslint
pnpm add -Dw eslint@^9.18.0 , @eslint-community/eslint-plugin-eslint-comments@^4.4.1

# globals เอาไว้ใช้ set environment ใน eslint เพื่อให้รู้ว่า จะต้อง ignore keyword document,localstorage เมื่อ set environment เป็น globals.browser เป็นต้น
pnpm add -Dw globals

#=========

# config eslint for typescript
pnpm add -Dw @typescript-eslint/parser @typescript-eslint/eslint-plugin @eslint/js

# config plugin สำหรับ react,nextjs ถ้าใน workspace มี project type ใช้  nextjs,react หลายๆProject
pnpm add -Dw @next/eslint-plugin-next eslint-plugin-react eslint-plugin-react-hooks

# config eslint for jest เพื่อให้ ทุก project type สามารถใช้ jest ได้
pnpm add -Dw eslint-plugin-jest

# config prittier ให้ใช้งานให่้ กับ eslint
pnpm add -Dw  eslint-config-prettier 

cd $CUR_PATH

# create config file jest,eslint
 cp $GENERATOR_DIR/script-generator/template/project/.prettierignore $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp $GENERATOR_DIR/script-generator/template/project/.prettierrc $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp $GENERATOR_DIR/script-generator/template/project/root-eslint.config.mjs $WORKSPACE_DIR/workspaces/$SYSTEM_DIR
 cp -r $GENERATOR_DIR/script-generator/template/project/jest.config* $WORKSPACE_DIR/workspaces/$SYSTEM_DIR/

# ===============

# install vite และ plugin  สำหรับ sub project type ui,features
cd $WORKSPACE_DIR/workspaces/$SYSTEM_DIR

pnpm add -Dw vite @vitejs/plugin-react vite-plugin-dts vite-plugin-lib-inject-css vite-plugin-sass-dts

# install Rollup Plugin 
# rollup-plugin-node-externals  สำหรับ unbundle dependency ใน package.json
# rollup-plugin-preserve-directives เพื่อให้ ไม่ถูก remove comment 'use client' หลังจาก bunble
pnpm add -Dw rollup rollup-plugin-node-externals rollup-plugin-preserve-directives

# instll glob สำหรับใช้ ในการ config vite ใน sub project type ui,features
pnpm add -Dw glob
#=====

# install msw สำหรับ ใช้ mock httpClient ของ project type featues ,web หรือ service
pnpm add -Dw msw 
# ใช้ jest-fixed-jsdom แทน jest-environment-jsdom เพื่อ แก้ปัญหา msw v2 Error Request/Response/TextEncoder is not defined (Jest)
pnpm add -Dw jest-fixed-jsdom
#======

# install storybook
# ติดตั้ง dependencies ที่ root
pnpm add -Dw storybook@^8.0.0 @storybook/addon-essentials @storybook/addon-interactions @storybook/addon-links @storybook/blocks @storybook/react @storybook/react-vite @storybook/test msw-storybook-addon
# pnpm add -Dw storybook@^8.0.0 @storybook/cli @storybook/addon-essentials @storybook/addon-interactions @storybook/addon-links @storybook/blocks @storybook/react @storybook/react-vite @storybook/test @storybook/testing-library msw-storybook-addon
# =========



# Package สำหรับ Project Web,Feature,ui-component ที่ใช้งานบ่อยๆ
# for GTM
# pnpm add -w @next/third-parties@^14.2.12

# for onBoarding feature
# pnpm add -w react-joyride@^2.9.2
# customization(position,style) of react-joyride 
# pnpm add -w react-floater@^0.9.4

# devDependencires (ยังไม่รู้ใช้ทำอะไร) และต้อง config ที่ื nextjs.config ด้วย เพื่อให้ ฺBuild Project Nextjsผ่าน
pnpm add -Dw raw-loader@^4.0.2

# ============
pnpm update -i

# # ติดตั้ง dependencies เพิ่มเติมสำหรับ development
# pnpm add -D vite @vitejs/plugin-react autoprefixer postcss tailwindcss storybook-dark-mode @storybook/addon-styling @storybook/addon-a11y chromatic
# #=====



    