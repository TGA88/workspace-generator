FROM node:20-alpine

WORKDIR /app/standalone

ENV NODE_ENV production
ENV PORT 3000

COPY dist/apps/demo-exm-web/nextjs/standalone ./

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system nextjs 1001

RUN chown -R nextjs:nodejs apps/
RUN chmod +x ./next-start.sh

RUN apk add --no-cache bash gettext

USER nextjs

EXPOSE ${PORT}

ENTRYPOINT ["bash","next-start.sh","demo-exm-web","nextjs"]
