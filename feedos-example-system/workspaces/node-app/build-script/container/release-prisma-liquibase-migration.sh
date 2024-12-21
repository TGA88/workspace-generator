# ex. feed-portal-webapi
APP_NAME=$1   
# ex. store-prisma
APP_TYPE=$2
# PACKAGE_NAME=$3

# # run pnpm deploy
# rm -rf deploy/$APP_NAME/$APP_TYPE
# pnpm -F $PACKAGE_NAME --prod deploy deploy/$APP_NAME/$APP_TYPE

# # run build
# cd deploy/$APP_NAME/$APP_TYPE && pnpm build
# cd $WORKSPACE

# make source db migration
rm -rf release/db/$APP_NAME-$APP_TYPE/store-prisma && mkdir -p release/db/$APP_NAME-$APP_TYPE/store-prisma/
cp -r libs/$APP_NAME/store-prisma/prisma release/db/$APP_NAME-$APP_TYPE/store-prisma/
cp -r libs/$APP_NAME/store-prisma/liquibase release/db/$APP_NAME-$APP_TYPE/store-prisma/
# cp -r libs/$APP_NAME/store-prisma/.env release/db/$APP_NAME-$APP_TYPE/store-prisma/
# cp -r libs/$APP_NAME/store-prisma/Dockerfile release/db/$APP_NAME-$APP_TYPE/store-prisma/

# make container to run source db
rm -rf release/container-apps/$APP_NAME-$APP_TYPE/ && mkdir -p release/container-apps/$APP_NAME-$APP_TYPE/store-prisma/
cp -r libs/$APP_NAME/store-prisma/.env release/container-apps/$APP_NAME-$APP_TYPE/store-prisma/
cp -r libs/$APP_NAME/store-prisma/initdb release/container-apps/$APP_NAME-$APP_TYPE/store-prisma/
cp -r libs/$APP_NAME/store-prisma/Dockerfile release/container-apps/$APP_NAME-$APP_TYPE/store-prisma/Dockerfile
cp -r libs/$APP_NAME/store-prisma/docker-compose.yml release/container-apps/$APP_NAME-$APP_TYPE/store-prisma/
cp -r libs/$APP_NAME/store-prisma/package.json release/container-apps/$APP_NAME-$APP_TYPE/store-prisma/
# cp -r pnpm-lock.yaml release/db/$APP_NAME-$APP_TYPE/store-prisma/