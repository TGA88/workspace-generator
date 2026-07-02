# demo-exm-webapi — multi-stage build (black-box api-test target)
# build context = workspaces/node-app (ดู docker-compose api.build.context) · .dockerignore กัน host artifacts
# bookworm-slim (debian, openssl3) ให้ตรง prisma binaryTarget debian-openssl-3.0.x
#
# ⚠️ import ข้าม workspace resolve ด้วย require -> dist (ไม่ใช่ development condition) → ต้อง build ทุก lib
#    ที่ webapi พึ่ง (core/service/store-prisma) ก่อน แล้ว tsc webapi → dist/src/app.js
# ⚠️ ชื่อ package (@gu-example-system/..) / service (demo-exm-webapi) / data (exm-data) = placeholder
#    ที่ new-webapi.sh sed แทน · filter สมมติ API_PKG=shared-api (default) — ถ้าใช้ชื่ออื่นต้องแก้ filter

# ---------- build ----------
FROM node:22-bookworm-slim AS build
RUN npm install -g pnpm@10.4.1
WORKDIR /app

# copy ทั้ง workspace (source เท่านั้น — node_modules/dist/generated ถูก .dockerignore กันไว้)
COPY . .

RUN pnpm install --no-frozen-lockfile

# prisma client (linux engine ของ bookworm) — ต้องก่อน build store-prisma (tsup bundle dbclient)
RUN pnpm --filter @gu-example-system/exm-data-store-prisma prisma:generate

# build libs (tsup) ตามลำดับ dependency → dist ต่อ subpath (require resolve) แล้ว tsc webapi
RUN pnpm --filter @gu-example-system/shared-api-core build \
 && pnpm --filter @gu-example-system/exm-data-store-prisma exec tsup --config ../../../../tsup.lib.config.ts \
 && pnpm --filter @gu-example-system/shared-api-service build \
 && pnpm --filter demo-exm-webapi-mcs-fastify build

# ---------- runtime ----------
FROM node:22-bookworm-slim AS runtime
ENV NODE_ENV=production
WORKDIR /app
# copy ทั้ง tree ที่ build แล้ว (pnpm symlink node_modules + dist + generated engine คงโครง path เดียวกัน)
COPY --from=build /app /app
WORKDIR /app/apps/demo-exm-webapi/mcs-fastify

# fastify-cli รัน dist/src/app.js (ไม่ใช่ main.ts) · -a 0.0.0.0 ให้ reachable ผ่าน port map · PORT จาก env
EXPOSE 3000
CMD ["./node_modules/.bin/fastify", "start", "-a", "0.0.0.0", "-l", "info", "dist/src/app.js"]
