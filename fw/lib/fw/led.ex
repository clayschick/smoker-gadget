defmodule Fw.Led do
  @moduledoc false

  @default_adapter Fw.Adapters.Pwm

  def adjust(pid_output) do
    config = Application.get_env(:fw, Fw.Temperature, [])
    adapter = config[:pwm_adapter] || @default_adapter

    adapter.adjust(pid_output)

    :ok
  end
end
