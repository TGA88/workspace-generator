# Copy dependency for hosting (linux-alpine) in Docker
echo "copy libquery_engine-linux-musl-openssl-x.x.x.so.node to release folder"
for file in $(find node_modules/prisma/ | grep "libquery_engine-linux-musl" );
do
  echo "cp $file root"
  cp $file .
done