defmodule Fw.Adapters.Pwm do
  @moduledoc """

  """
  require Logger

  alias Pigpiox.Pwm

  def adjust(frequency, duty_cycle) do
    # Need to make these args configurable
    Pigpiox.Pwm.hardware_pwm(18, frequency, duty_cycle)
  end

  def stop do
    Pigpiox.Pwm.hardware_pwm(18, 25_000, 0)
  end
end
