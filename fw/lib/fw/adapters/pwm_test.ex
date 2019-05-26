defmodule Fw.Adapters.PwmTest do
  @moduledoc false

  alias Fw.Adapters.SpiTest

  @behaviour Fw.Adapters.PwmBehaviour

  @impl true
  def set_duty_cycle(pid_output) do
    SpiTest.fake_temp_adjustment(pid_output)
    :ok
  end
end
