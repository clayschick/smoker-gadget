defmodule Pid.Agent do
  @moduledoc """
  State used by the PID Controller.
  """
  defmodule State do
    @moduledoc """
    Struct representing the PID Controller state.
    """
    defstruct kp: 0,
              ki: 0,
              kd: 0,
              setpoint: 0,
              accumulation_of_error: 0,
              last_time: 0,
              last_input: 0,
              last_output: 0,
              last_error: 0,
              i_term: 0
  end

  use Agent

  @doc """
  Use Keyword.fetch!/2 for required fields in the options list
  """
  def start_link(_option_list \\ []), do:
    Agent.start_link(fn -> %State{} end, name: __MODULE__)

  def update(new_state_fields), do:
    Agent.update(__MODULE__, &struct!(&1, new_state_fields))

  def get_state, do: Agent.get(__MODULE__, & &1)

  def reset, do: Agent.update(__MODULE__, fn state -> %State{} end)
end
