ARG BUILD_IMAGE="node:18-slim"
ARG RUN_IMAGE="node:18-alpine"

FROM $BUILD_IMAGE AS builder
WORKDIR /app

ARG SRC_DIR=""

COPY ./${SRC_DIR}/package.json ./
COPY ./${SRC_DIR}/package-lock.json ./
RUN npm ci

COPY ${SRC_DIR} .

RUN npm run build

########

FROM $RUN_IMAGE
WORKDIR /app

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

EXPOSE 3000
CMD ["npm", "run", "start:prod"]
