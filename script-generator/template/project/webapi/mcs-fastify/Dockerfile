FROM node:22-alpine

# ENV PNPM_HOME="/pnpm"
# ENV PATH="$PNPM_HOME:$PATH"
# RUN corepack enable
RUN npm install --global pnpm

COPY /dist/apps/demo-exm-webapi/mcs-fastify /app

WORKDIR /app

CMD [ "pnpm", "start" ]