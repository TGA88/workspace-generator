#!/usr/bin/env bash

APP_NAME=$1
APP_TYPE=$2

echo "ENV FOR NEXTJS CLIENT_SIDE"
printenv | grep NEXT

export EXISTING_VARS=$(printenv | awk -F= '{print $1}' | sed 's/^/\$/g' | grep NEXT | paste -sd, );

for file in $(find ./apps/$APP_NAME/$APP_TYPE/.next/ -name '*.js');
do
  envsubst $EXISTING_VARS < $file > $file.tmp && mv $file.tmp $file
done

echo "ENV AFTER REPLACE"
printenv | grep NEXT

node apps/$APP_NAME/$APP_TYPE/server.js