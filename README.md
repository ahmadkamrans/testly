Master branch: [![CircleCI](https://circleci.com/gh/BryxenTestly/testly_umbrella/tree/master.svg?style=svg&circle-token=e71dc518f407973056f8f780d42be84debb47381)](https://circleci.com/gh/BryxenTestly/testly_umbrella/tree/master)

Stage branch: [![CircleCI](https://circleci.com/gh/BryxenTestly/testly_umbrella/tree/stage.svg?style=svg&circle-token=e71dc518f407973056f8f780d42be84debb47381)](https://circleci.com/gh/BryxenTestly/testly_umbrella/tree/stage)

# Testly Umbrella Apps

* testly - business logic and persistence, used by other apps
* testly_api:4001 - graphql API for dashboard
* testly_mailer - mailer app
* testly_recorder_api:4002 - web API for recorder script
* testly_home:4000 - main site pages
* testly_smart_proxy_web:4003 - assets proxy of session recordings
* testly_admin:4004 - testly admin web dashboard


# Development

1. mix deps.get
2. mix ecto.setup
3. mix phx.server

# Arc

For local development we use Arc.Storage.Local. Unfortunately it doesn't support
asset_host, so we use Testly.ArcFixer and waiting for `https://github.com/stavro/arc/pull/65` to merge.

Also, all files will be uploaded to `uploads` root dir(like at AWS, so we avoid excess configuration), and served by home endpoint:

```elixir
if Keyword.fetch!(Application.fetch_env!(:testly_home, TestlyHome.Endpoint), :serve_local_uploads) do
  plug(Plug.Static,
    at: "/uploads",
    from: "uploads",
    gzip: false
  )
end
```

# Git Hooks
Check docs: https://github.com/qgadrian/elixir_git_hooks
Run `mix git_hooks.install` to generate hooks from our config.


## Apps:
### Testly

#### geolix

1. Download country/city maxmind databases (https://dev.maxmind.com/geoip/geoip2/geolite2/)

2. Put them to `apps/testly/priv/geo`

#### ua_inspector

1. `mix ua_inspector.download.databases`
2. `mix ua_inspector.download.short_code_maps`
3. Check `apps/testly/priv/user_agent` for files

#### ref_inspector
1. `mix ref_inspector.download`
2. Check `apps/testly/priv/referrer` for files

# Deploying

CircleCI will trigger AWS deploy on stage/master success build
