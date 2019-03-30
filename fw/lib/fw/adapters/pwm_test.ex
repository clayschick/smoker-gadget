defmodule Fw.Adapters.PwmTest do
  @moduledoc """
  Specification for a fake PWM adapter.
  """

  alias Fw.Adapters.SpiTest

  # I shall abide by the adapter rules
  @behaviour Fw.Adapters.PwmBehaviour

  @impl true
  def adjust(pid_output) do
    SpiTest.fake_temp_adjustment(pid_output)
    :ok
  end
end
