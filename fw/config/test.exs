use Mix.Config

config :fw, Fw.Temperature,
  spi_adapter: Fw.Adapters.SpiTest,
  pwm_adapter: Fw.Adapters.PwmTest
