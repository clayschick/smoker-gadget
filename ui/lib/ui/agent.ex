defmodule Ui.Agent do
  @moduledoc """
  Used to hold the `auto` status of the controller.
  """

  use Agent

  def start_link(_args, _option_list \\ []),
    do: Agent.start_link(fn -> false end, name: __MODULE__)

  def is_auto?(), do: Agent.get(__MODULE__, & &1)

  def set_auto(val), do: Agent.update(__MODULE__, fn _ -> val end)
end
