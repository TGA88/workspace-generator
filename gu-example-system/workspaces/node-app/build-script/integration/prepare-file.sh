WORKSPACE=$PWD
APP_NAME=$1
APP_TYPE=$2
PACKAGE_NAME=$3

echo "current workspace: $WORKSPACE"
#run pnpm deploy
rm -rf apps/$APP_NAME/$APP_TYPE/build-integretion-test
pnpm -F $PACKAGE_NAME --prod deploy apps/$APP_NAME/$APP_TYPE/build-integretion-test

#run build
cd apps/$APP_NAME/$APP_TYPE/build-integretion-test/$APP_NAME/$APP_TYPE && pnpm build
cd $WORKSPACE