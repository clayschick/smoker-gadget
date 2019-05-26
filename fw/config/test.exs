use Mix.Config

config :fw, Fw.Temperature,
  spi_adapter: Fw.Adapters.SpiTest

config :fw, Fw.Fan,
  pwm_adapter: Fw.Adapters.PwmTest,
  pwm_pin: 18,
  pwm_frequency: 25_000
