WORKSPACE=$PWD
APP_NAME=$1
APP_TYPE=$2
PACKAGE_NAME=$3

echo "current workspace: $WORKSPACE"

# run pnpm deploy
rm -rf deploy/$APP_NAME/$APP_TYPE
pnpm -F $PACKAGE_NAME --prod deploy deploy/$APP_NAME/$APP_TYPE



# run build
cd deploy/$APP_NAME/$APP_TYPE && pnpm build
cd $WORKSPACE

# create release folder
echo "remove release folder /release/container-apps/$APP_NAME/$APP_TYPE"
rm -rf /release/container-apps/$APP_NAME/$APP_TYPE
echo "create release folder /release/container-apps/$APP_NAME/$APP_TYPE"
mkdir -p release/container-apps/$APP_NAME/$APP_TYPE

echo "copy Dockerfile to release folder"
cp deploy/$APP_NAME/$APP_TYPE/Dockerfile $WORKSPACE/release/container-apps/$APP_NAME/$APP_TYPE/

rm -rf release/dist/apps/$APP_NAME/$APP_TYPE
mkdir -p release/dist/apps/$APP_NAME/$APP_TYPE

# echo "copy libquery_engine-linux-musl-openssl-x.x.x.so.node to release folder"
# for file in $(find node_modules/prisma/ | grep libquery_engine-linux-musl-openssl-);
# do
#   echo "cp $file root"
#   cp $file release/dist/apps/$APP_NAME/$APP_TYPE/
# done


# Copy Source code for release
cp -r deploy/$APP_NAME/$APP_TYPE/dist/* release/dist/apps/$APP_NAME/$APP_TYPE
cp -rP deploy/$APP_NAME/$APP_TYPE/node_modules release/dist/apps/$APP_NAME/$APP_TYPE/
cp deploy/$APP_NAME/$APP_TYPE/package.json release/dist/apps/$APP_NAME/$APP_TYPE/
echo "Copy Source code for release success!"