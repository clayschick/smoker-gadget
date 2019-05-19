defmodule Fw.Adapters.PwmTest do
  @moduledoc """
  Specification for a fake PWM adapter.
  """

  def adjust(_, pid_output) do
    Fw.Adapters.SpiTest.fake_temp_adjustment(pid_output)
    :ok
  end

  def stop(), do: :ok
end
