# ---------- BUILD STAGE ----------
FROM node:20-alpine AS build

WORKDIR /app

# Required for native deps (sqlite)
RUN apk add --no-cache python3 make g++

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# ---------- RUNTIME STAGE ----------
FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache dumb-init

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/build ./build
COPY --from=build /app/config ./config
COPY --from=build /app/src ./src
COPY --from=build /app/public ./public

ENV NODE_ENV=production
ENV STRAPI_DISABLE_UPDATE_NOTIFICATION=true

EXPOSE 1337

ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "start"]
