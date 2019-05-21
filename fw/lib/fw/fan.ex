defmodule Fw.Fan do
  @moduledoc """
  Using the Pigpiox library to adjust a 4-wire PWM fan.

  Currently using a 4-pin PWM enabled fan. The PWM pin on the
  fan is `5v` and `25_000Hz` frequency.

  The PI is only `3.3v` output but is enough to drive the PWM.

  The max frequency is 1_000_000. At a frequency of 25_000 the
  fan will start at a dutycycle of 94_000 and stops at 50_000.
  NOTE: the example values above need updated

  The fan does not start and stop at the same dutycycle value.
  """

  require Logger

  @default_adapter Fw.Adapters.Pwm

  def adjust(pid_output) do
    config = Application.get_env(:fw, Fw.Fan, [])
    adapter = config[:pwm_adapter] || @default_adapter

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
