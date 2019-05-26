defmodule Fw.Adapters.PwmBehaviour do
  @moduledoc """
  Specification for PWM behaviour
  """
  @callback set_duty_cycle(level :: float()) :: :ok | {:error, String.t()}
end
