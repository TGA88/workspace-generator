#!/bin/bash

APP_NAME=$1

# copy app is compiled to dist folder
echo "remove dist folder /dist/apps/storybook-host-$APP_NAME"
rm -rf /dist/apps/storybook-host-$APP_NAME
echo "create dist folder /dist/apps/storybook-host-$APP_NAME"
mkdir -p dist/apps/storybook-host-$APP_NAME

cp -r storybook-host/$APP_NAME/storybook-static/* dist/apps/storybook-host-$APP_NAME

# copy app is compiled to release folder
echo "remove release folder /release/static-apps/storybook-host-$APP_NAME"
rm -rf /release/static-apps/storybook-host-$APP_NAME
echo "create release folder /release/static-apps/storybook-host-$APP_NAME"
mkdir -p release/static-apps/storybook-host-$APP_NAME

cp -r storybook-host/$APP_NAME/storybook-static/* release/static-apps/storybook-host-$APP_NAME

# Copy Source code for release
echo "remove release folder /release/dist/apps/storybook-host-$APP_NAME"
rm -rf release/dist/apps/storybook-host-$APP_NAME
echo "create release folder /release/dist/apps/storybook-host-$APP_NAME/"
mkdir -p release/dist/apps/storybook-host-$APP_NAME

cp -r dist/apps/storybook-host-$APP_NAME/* release/dist/apps/storybook-host-$APP_NAME/

