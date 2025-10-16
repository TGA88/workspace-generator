#!/usr/bin/env bash
APP_NAME=$1
APP_TYPE=$2
 
set -a
source .env.development
set +a
echo "ENV FOR NEXTJS CLIENT_SIDE"
printenv | grep NEXT
 
export EXISTING_VARS=$(printenv | awk -F= '{print $1}' | sed 's/^/\$/g' | grep NEXT | paste -sd, );
 
for file in $(find ./ -type f -name '*.js');
do
  echo "Replacing env vars in $file"
  envsubst $EXISTING_VARS < $file > $file.tmp && mv $file.tmp $file
done
 
echo "ENV AFTER REPLACE"
printenv | grep NEXT