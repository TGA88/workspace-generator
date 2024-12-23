#!/bin/bash

APP_NAME=$1
APP_TYPE=$2

# copy app is compiled to dist folder
echo "remove dist folder /dist/apps/$APP_NAME/$APP_TYPE"
rm -rf /dist/apps/$APP_NAME/$APP_TYPE
echo "create dist folder /dist/apps/$APP_NAME/$APP_TYPE"
mkdir -p dist/apps/$APP_NAME/$APP_TYPE

cp -r apps/$APP_NAME/$APP_TYPE/.next dist/apps/$APP_NAME/$APP_TYPE
cp -r apps/$APP_NAME/$APP_TYPE/public dist/apps/$APP_NAME/$APP_TYPE/.next/standalone/apps/$APP_NAME/$APP_TYPE/
cp -r dist/apps/$APP_NAME/$APP_TYPE/.next/static dist/apps/$APP_NAME/$APP_TYPE/.next/standalone/apps/$APP_NAME/$APP_TYPE/.next/
cp script/next-start.sh dist/apps/$APP_NAME/$APP_TYPE/.next/standalone/


# copy app is compiled to release folder
echo "remove release folder /release/container-apps/$APP_NAME/$APP_TYPE"
rm -rf /release/container-apps/$APP_NAME/$APP_TYPE
echo "create release folder /release/container-apps/$APP_NAME/$APP_TYPE"
mkdir -p release/container-apps/$APP_NAME/$APP_TYPE

echo "copy Dockerfile to release folder"
cp apps/$APP_NAME/$APP_TYPE/Dockerfile release/container-apps/$APP_NAME/$APP_TYPE/
cp apps/$APP_NAME/$APP_TYPE/.env.development release/container-apps/$APP_NAME/$APP_TYPE/.env

# Copy Source code for release
echo "remove release folder /release/dist/apps/$APP_NAME/$APP_TYPE"
rm -rf release/dist/apps/$APP_NAME/$APP_TYPE
echo "create release folder /release/dist/apps/$APP_NAME/$APP_TYPE/"
mkdir -p release/dist/apps/$APP_NAME/$APP_TYPE

cp -r dist/apps/$APP_NAME/$APP_TYPE/.next/standalone release/dist/apps/$APP_NAME/$APP_TYPE/

