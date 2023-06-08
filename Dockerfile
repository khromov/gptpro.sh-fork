FROM node:19.7-alpine AS sk-build
WORKDIR /usr/src/app

ARG TZ=Europe/Stockholm
ARG PUBLIC_BASE_URL
ARG PUBLIC_PUSHPIN_URL
ARG PUBLIC_SENTRY_DSN
ARG PUBLIC_VAPID_PUBLIC_KEY

COPY . /usr/src/app
RUN apk --no-cache add curl tzdata
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN npm install
RUN npm run build:node

FROM node:19.7-alpine
WORKDIR /usr/src/app

ARG TZ=Europe/Stockholm
RUN apk --no-cache add curl tzdata
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=sk-build /usr/src/app/package.json /usr/src/app/package.json
COPY --from=sk-build /usr/src/app/package-lock.json /usr/src/app/package-lock.json
COPY --from=sk-build /usr/src/app/migrations /usr/src/app/migrations

COPY --from=sk-build /usr/src/app/build-node /usr/src/app/build-node

EXPOSE 3000
CMD ["npm", "run", "start:node"]