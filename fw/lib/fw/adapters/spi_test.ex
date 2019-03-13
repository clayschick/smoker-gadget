defmodule Fw.Adapters.SpiTest do
  @moduledoc """
  Specification for a fake SPI adapter.

  I'm using an Agent whose state value is meant to represent
  the value returned from the RTD.
  """

  use Agent

  @behaviour Fw.Adapters.SpiBehaviour

  def start_link(_args \\ []) do
    Agent.start_link(fn -> 8283 end, name: __MODULE__)
  end

  @impl true
  def open(_device, _options) do
    {:ok, :erlang.make_ref()}
  end

  @impl true
  def transfer(_ref, _data) do
    rtd_value =
      Agent.get(__MODULE__, & &1)
      |> Kernel.trunc()

    {:ok, <<0::size(8), rtd_value::size(15), 0::size(1)>>}
  end

  def fake_temp_adjustment(pid_output) do
    Agent.update(__MODULE__, fn state -> state + pid_output end)
  end
end
