defmodule Fw.Adapters.SpiTest do
  @moduledoc false

  use Agent

  @behaviour Fw.Adapters.SpiBehaviour

  def start_link(_args \\ []) do
    IO.puts("Starting the test agent")
    Agent.start_link(fn -> 8283 end, name: __MODULE__)
  end

  @impl true
  def open(_device, _options) do
    {:ok, :erlang.make_ref()}
  end

  @impl true
  def transfer(_ref, _data) do
    rtd_value =
      Agent.get(__MODULE__, & trunc(&1))

    {:ok, <<0::size(8), rtd_value::size(15), 0::size(1)>>}
  end

  def fake_temp_adjustment(pid_output) do
    Agent.update(__MODULE__, fn state -> state + pid_output end)
  end
end
