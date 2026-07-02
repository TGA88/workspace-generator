# demo-exm-webapi — multi-stage build (black-box api-test target)
# build context = workspaces/node-app (ดู docker-compose api.build.context) · .dockerignore กัน host artifacts
# bookworm-slim (debian, openssl3) ให้ตรง prisma binaryTarget debian-openssl-3.0.x
#
# build ด้วย **nx scripts ของ repo** (run-many, เลือก project explicit): build:backend-libs (core/service/store-prisma)
#   ก่อน แล้ว build:backend-apps (webapi) · store-prisma build รวม `prisma:generate` → prisma client มาพร้อม
#   (⚠️ `nx run <app>:build` ที่พึ่ง `^build` ไม่ build deps ในคอนเทนเนอร์ — ใช้ build:backend-libs/apps ที่ระบุ project ตรง ๆ)
#   · demo-exm-webapi = service placeholder (new-webapi.sh sed แทน)

# ---------- build ----------
FROM node:22-bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends openssl ca-certificates bash git \
  && rm -rf /var/lib/apt/lists/*
RUN corepack enable
WORKDIR /app

# copy ทั้ง workspace (source เท่านั้น — node_modules/dist/generated ถูก .dockerignore กันไว้)
COPY . .

RUN pnpm install --no-frozen-lockfile
# nx run-many (repo scripts): backend libs (**/*api-*, **/*-data-store*) ก่อน แล้ว backend apps (*webapi*)
RUN NX_DAEMON=false pnpm run build:backend-libs && NX_DAEMON=false pnpm run build:backend-apps

# ---------- runtime ----------
FROM node:22-bookworm-slim AS runtime
# openssl = prisma query engine ต้องใช้ (bookworm-slim ไม่มีมาให้) — ไม่งั้น engine mismatch (openssl 3.0.x)
RUN apt-get update && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*
ENV NODE_ENV=production
WORKDIR /app
# copy ทั้ง tree ที่ build แล้ว (pnpm symlink node_modules + dist + generated engine คงโครง path เดียวกัน)
COPY --from=build /app /app
WORKDIR /app/apps/demo-exm-webapi/mcs-fastify

# fastify-cli รัน dist/src/app.js (ไม่ใช่ main.ts) · -a 0.0.0.0 ให้ reachable ผ่าน port map · PORT จาก env
EXPOSE 3000
CMD ["./node_modules/.bin/fastify", "start", "-a", "0.0.0.0", "-l", "info", "dist/src/app.js"]
