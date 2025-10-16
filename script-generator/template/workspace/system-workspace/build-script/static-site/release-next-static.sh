APP_NAME=$1
APP_TYPE=$2
PACKAGE_NAME=$3
pwd
echo "APP_NAME: $APP_NAME"
echo "APP_TYPE: $APP_TYPE"

ls -la


mkdir -p release/static-apps/$PACKAGE_NAME
cp -rP apps/$APP_NAME/$APP_TYPE/static-apps/$PACKAGE_NAME/* release/static-apps/$PACKAGE_NAME
cp build-script/container/next-start-static.sh release/static-apps/$PACKAGE_NAME
cp -rP apps/$APP_NAME/$APP_TYPE/next.config.mjs release/static-apps/$PACKAGE_NAME
cp -rP apps/$APP_NAME/$APP_TYPE/package.json release/static-apps/$PACKAGE_NAME
# mv dist/apps/$APP_NAME/$APP_TYPE/exported/* release/static-apps/$APP_NAME

# copy dockerfile for artifact static site output
cp -rP apps/$APP_NAME/$APP_TYPE/Dockerfile.artifact-static release/static-apps/Dockerfile.artifact-$PACKAGE_NAME
