use Mix.Config

config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

config :fw, Fw.Temperature,
  spi_adapter: Fw.Adapters.SpiTest,
  pwm_adapter: Fw.Adapters.PwmTest

config :ui, UiWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  http: [port: 4000],
  debug_errors: true,
  # code_reloader: true,
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../../ui/assets", __DIR__)
    ]
  ]

# I can not get the live reload working so I still have to
# restart my iex session when in dev env
# config :ui, UiWeb.Endpoint,
#   live_reload: [
#     dirs: [
#       Path.expand("../../ui/priv/static", __DIR__),
#       Path.expand("../../ui/priv/gettext", __DIR__),
#       Path.expand("../../ui/lib/ui_web/views", __DIR__),
#       Path.expand("../../ui/lib/ui_web/templates/page", __DIR__)
#     ]
#   ]
# config :ui, UiWeb.Endpoint,
#   live_reload: [
#     patterns: [
#       ~r{../../ui/priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
#       ~r{../../ui/priv/gettext/.*(po)$},
#       ~r{../../ui/lib/ui_web/views/.*(ex)$},
#       ~r{../../ui/lib/ui_web/templates/.*(eex)$}
#     ]
#   ]
