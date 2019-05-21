defmodule Fw.Adapters.Pwm do
  @moduledoc false

  alias Pigpiox.Pwm

  # Need to make these args configurable
  def adjust(frequency, duty_cycle), do: Pwm.hardware_pwm(18, frequency, duty_cycle)

  def stop, do: Pwm.hardware_pwm(18, 25_000, 0)
end
