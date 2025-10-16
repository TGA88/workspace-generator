# Copy dependency for hosting (linux-alpine) in Docker
echo "copy libquery_engine-linux-musl-openssl-x.x.x.so.node to dist folder"
for file in $(find node_modules/prisma/ | grep "libquery_engine-linux-musl-"); do
  echo "cp $file dist/"
  cp "$file" dist/
done
