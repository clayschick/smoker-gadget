defmodule Ui.PidControl do
  @moduledoc """
  Starts and stops the Tasks that will run the controller
  and the update to the UI.
  """

  alias Ui.Agent, as: UiState
  alias Pid.Agent, as: PidState

  @doc """
  Stops the controller and ui update task by setting the
  Ui.Agent.auto to false.
  """
  def stop(), do: UiState.set_auto(false)

  @doc """
  Sets the UI auto state to true and sets initial PID
  state values from the UI.

  Starts a Task that will update the UI.
  """
  def start(setpoint, kp, ki, kd) do
    :ok = UiState.set_auto(true)

    :ok =
      PidState.update(
        setpoint: setpoint,
        kp: kp,
        ki: ki,
        kd: kd
      )

    {:ok, _} = Task.start(fn -> ui_loop(true) end)

    :ok
  end

  @doc """
  Retrieves the controller results and broadcast them to the UI.

  Runs in a Task.
  """
  def ui_loop(_ = true) do
    Pid.Controller.cycle() |> broadcast_to_ui()

    ui_loop(UiState.is_auto?())
  end

  def ui_loop(_ = false), do: :ok

  defp broadcast_to_ui({:ok, %{input: input, output: output}}) do
    UiWeb.Endpoint.broadcast("pid:control", "controller_updated", %{
      input: input,
      output: output
    })
  end
end
