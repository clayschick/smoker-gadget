defmodule Ui.PidControl do
  @moduledoc """
  Starts and stops the Tasks that will run the controller
  and the update to the UI.
  """

  alias Ui.Agent, as: UiState
  alias Pid.Agent, as: PidState

  def start_stream(setpoint, kp, ki, kd) do
    :ok = UiState.set_auto(true)

    :ok =
      PidState.update(
        setpoint: setpoint,
        kp: kp,
        ki: ki,
        kd: kd
      )

    {:ok, _} = Task.start(fn -> update_ui_stream() end)

    :ok
  end

  # This function needs to return a value when we stop
  # the controller so that the Task is stopped
  def update_ui_stream() do
    Pid.Controller.eval_stream()
    |> Stream.map(fn {:ok, %{input: input, output: output}} ->
      UiWeb.Endpoint.broadcast("pid:control", "controller_updated", %{
        input: input,
        output: output
      })
    end)
    |> Stream.take_while(fn _ -> UiState.is_auto?() end)
    |> Stream.run()
  end

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
  def start_with_loop(setpoint, kp, ki, kd) do
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
  This function is ran in a Task and will retrieve the
  controller results and broadcast them to the UI.
  """
  def ui_loop(_ = true) do
    Pid.Controller.run_with() |> broadcast_to_ui()

    ui_loop(UiState.is_auto?())
  end

  def ui_loop(_ = false), do: :ok

  defp broadcast_to_ui({:ok, %{input: input, output: output}}) do
    UiWeb.Endpoint.broadcast("pid:control", "controller_updated", %{
      input: input,
      output: output
    })
  end

  @doc """
  Starts a Task with the controller function and a Task
  that starts a ui refresh/update function.
  """
  def start_loop(setpoint, kp, ki, kd) do
    :ok = UiState.set_auto(true)

    :ok =
      PidState.update(
        setpoint: setpoint,
        kp: kp,
        ki: ki,
        kd: kd
      )

    {:ok, _} = Task.start(fn -> Pid.Controller.run() end)

    {:ok, _} = Task.start(fn -> update_ui(true) end)

    :ok
  end

  @doc """
  Gets the controller state and sends the current values for
  input and output to the UI.

  This function is intended to ran in a Task. The task will run
  until the Pid.Agent.State.auto value is set to false.

  I don't like using the controllers state to determine
  when to return a value and stop the Task.

  I'd like to find a better option than recursion
  or a better way to do this in general, if there is one.
  """
  def update_ui(_ = false), do: :ok

  def update_ui(_ = true) do
    controller_state = PidState.get_state()

    UiWeb.Endpoint.broadcast("pid:control", "controller_updated", %{
      input: controller_state.last_input,
      output: controller_state.last_output
    })

    # I don't like this timer.
    Process.sleep(1000)

    update_ui(UiState.is_auto?())
  end
end
