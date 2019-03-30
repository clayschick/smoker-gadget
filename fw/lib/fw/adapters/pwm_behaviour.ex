defmodule Fw.Adapters.PwmBehaviour do
  @moduledoc """
  PWM adapter behaviour definition.
  """
  @callback adjust(pid_output::float()) :: :ok
end
