#!/bin/bash

APP_NAME=$1

# copy app is compiled to dist folder
echo "remove dist folder /dist/apps/$APP_NAME"
rm -rf /dist/apps/$APP_NAME
echo "create dist folder /dist/apps/$APP_NAME"
mkdir -p dist/apps/$APP_NAME

cp -r libs/$APP_NAME/storybook-static/* dist/apps/$APP_NAME

# copy app is compiled to release folder
echo "remove release folder /release/static-apps/$APP_NAME"
rm -rf /release/static-apps/$APP_NAME
echo "create release folder /release/static-apps/$APP_NAME"
mkdir -p release/static-apps/$APP_NAME

cp -r libs/$APP_NAME/storybook-static/* release/static-apps/$APP_NAME

# Copy Source code for release
echo "remove release folder /release/dist/apps/$APP_NAME"
rm -rf release/dist/apps/$APP_NAME
echo "create release folder /release/dist/apps/$APP_NAME/"
mkdir -p release/dist/apps/$APP_NAME

cp -r dist/apps/$APP_NAME/* release/dist/apps/$APP_NAME/

