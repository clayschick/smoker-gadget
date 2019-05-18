defmodule Fw.Adapters.Pwm do
  @moduledoc """
  Specification for a production PWM adapter.
  """

  alias Pigpiox.Pwm

  require Logger

  # I shall abide by the adapter rules
  @behaviour Fw.Adapters.PwmBehaviour

  # This need to accept a multiplier value
  def adjust(pid_output) do
    Logger.debug("pid_output: #{pid_output}")

    adjustment_variable =
      cond do
        pid_output < 0 -> 0
        true -> Kernel.trunc(pid_output)
      end

    Logger.debug("adjustment_variable: #{adjustment_variable}")

    Pwm.hardware_pwm(18, 100, adjustment_variable)

    adjustment_variable
  end
end
