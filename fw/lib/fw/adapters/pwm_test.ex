defmodule Fw.Adapters.PwmTest do
  @moduledoc false

  @behaviour Fw.Adapters.PwmBehaviour

  @impl true
  def set_duty_cycle(pid_output) do
    Fw.Adapters.SpiTest.fake_temp_adjustment(pid_output)
    :ok
  end
end
