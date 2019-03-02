use Mix.Config

config :fw, Fw.Temperature,
  spi_adapter: Fw.Adapters.Spi,
  pwm_adapter: Fw.Adapters.Pwm,
  device_bus: "spidev0.0",
  mode: 1,
  speed_hz: 500_000

config :ui, UiWeb.Endpoint,
  url: [host: "nerves.local"],
  http: [port: 80],
  server: true,
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2],
  root: Path.dirname(__DIR__),
  code_reloader: false,
  secret_key_base: "J2cLKeQh6EGm7txR56buroP4Tnvi+XjknT0qqnyyuqIWp8EsA/tmInmkXLYm9+2M",
  render_errors: [view: UiWeb.ErrorView, accepts: ~w(html json)]
