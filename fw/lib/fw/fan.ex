defmodule Fw.Fan do

  require Logger

  @default_adapter Fw.Adapters.Pwm

  def adjust(pid_output) do
    config = Application.get_env(:fw, Fw.Fan, [])
    adapter = config[:pwm_adapter] || @default_adapter

    # The fan does not start and stop at the same frequency.
    # At a frequency of 25_000 the fan will start at 94_000 and stop at 50_000
    # The max frequency is 1_000_000

    frequency = min(pid_output * 1000, 1_000_000) |> trunc

    Logger.debug("PWM frequency: #{frequency}")

    adapter.adjust(25_000, frequency)

    :ok
  end

  def stop do
    config = Application.get_env(:fw, Fw.Fan, [])
    adapter = config[:pwm_adapter] || @default_adapter

    adapter.stop()

    :ok
  end
end
