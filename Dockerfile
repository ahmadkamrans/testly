ARG APP_NAME

FROM elixir:1.8-alpine as builder
RUN apk add --no-cache \
  gcc \
  git \
  make \
  musl-dev
RUN mix local.rebar --force && \
  mix local.hex --force
WORKDIR /app
ENV MIX_ENV=prod

FROM builder as deps
WORKDIR /app
COPY mix.* ./
RUN mkdir -p \
  apps/testly \
  apps/testly_api \
  apps/testly_home \
  apps/testly_mailer \
  apps/testly_recorder_api \
  appstestly_smart_proxy_web
COPY apps/testly/mix.* apps/testly/
COPY apps/testly_api/mix.* apps/testly_api/
COPY apps/testly_home/mix.* apps/testly_home/
COPY apps/testly_mailer/mix.* apps/testly_mailer/
COPY apps/testly_recorder_api/mix.* apps/testly_recorder_api/
COPY apps/testly_smart_proxy_web/mix.* apps/testly_smart_proxy_web/
RUN mix do deps.get --only prod, deps.compile

FROM node:10.12-alpine as home-frontend
WORKDIR /app/apps/testly_home/assets
COPY apps/testly_home/assets/package*.json ./
COPY --from=deps /app/deps/phoenix /app/deps/phoenix
COPY --from=deps /app/deps/phoenix_html /app/deps/phoenix_html
RUN npm install
COPY apps/testly_home/assets .
RUN npm run deploy
RUN rm -Rf node_modules

FROM node:10.12-alpine as admin-frontend
WORKDIR /app/apps/testly_admin/assets
COPY apps/testly_admin/assets/package*.json ./
COPY --from=deps /app/deps/phoenix /app/deps/phoenix
COPY --from=deps /app/deps/phoenix_html /app/deps/phoenix_html
RUN npm install
COPY apps/testly_admin/assets .
RUN npm run deploy
RUN rm -Rf node_modules

FROM deps as releaser
ARG APP_NAME=testly
WORKDIR /app
COPY . .
COPY --from=home-frontend app/apps/testly_home /app/apps/testly_home
COPY --from=admin-frontend app/apps/testly_admin /app/apps/testly_admin
RUN mix do phx.digest, compile
RUN mix release --env=prod --profile=testly:prod --verbose \
  && mv _build/prod/rel/${APP_NAME} /app/release \
  && mv /app/release/bin/${APP_NAME} /app/release/bin/start_server

FROM elixir:1.8-alpine as testly
ENV MIX_ENV=prod REPLACE_OS_VARS=true
WORKDIR /app
RUN apk add --no-cache bash curl jq imagemagick
COPY --from=releaser /app/release /app/release
COPY rel/commands/start.sh .
EXPOSE 4000
EXPOSE 4001
EXPOSE 4002
EXPOSE 4003
EXPOSE 4004
CMD sh ./start.sh
