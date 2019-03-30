defmodule Fw.Adapters.Pwm do
  @moduledoc """
  Specification for a PWM adapter.
  """

  alias Pigpiox.Pwm

  require Logger

  # I shall abide by the adapter rules
  @behaviour Fw.Adapters.PwmBehaviour

  def adjust(pid_output) do
    Logger.debug("pid_output: #{pid_output}")
    # First arg is the frequency (makes it blink) - 0Hz to 100Hz (seems to be always on)
    # Second arg is the dutycycle - 0% to 100% (always on)
    # - this is what I will adjust with the pid_output
    # Pwm.hardware_pwm(12, 8000, 10000)
    # Pwm.hardware_pwm(12, 100, 900000) <-- this is super bright
    Pwm.hardware_pwm(12, 100, Kernel.trunc(pid_output) * 10)
    pid_output
  end
end
