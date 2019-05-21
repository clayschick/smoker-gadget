defmodule Fw.Adapters.PwmTest do
  @moduledoc false

  def adjust(pid_output) do
    Fw.Adapters.SpiTest.fake_temp_adjustment(pid_output)
    :ok
  end

  def stop(), do: :ok
end
