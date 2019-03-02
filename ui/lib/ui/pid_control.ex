defmodule Ui.PidControl do
  @moduledoc """
  Starts and stops the Tasks that will run the controller
  and the update to the UI.
  """

  @doc """
  Starts a Task with the controller function and a Task
  that starts a ui refresh/update function.

  This links to the current process but do I really care?
  """
  def start(%{"setpoint" => setpoint, "kp" => kp, "ki" => ki, "kd" => kd}) do
    Pid.Agent.update(
      auto: true,
      setpoint: String.to_integer(setpoint),
      kp: String.to_float(kp),
      ki: String.to_float(ki),
      kd: String.to_float(kd)
    )

    # If this function returned the last_input and last_ouput
    # on every cycle then I could use it to push up to the UI
    {:ok, _} = Task.start(fn -> Pid.Controller.run() end)

    {:ok, _} = Task.start(fn -> update_ui(%{auto: true}) end)

    :ok
  end

  @doc """
  Stops the controller and ui update task by setting the
  Pid.Agent.auto to false.
  """
  def stop(), do: Pid.Agent.update(auto: false)

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
  def update_ui(%{auto: false}), do: :ok

  def update_ui(%{auto: true}) do
    controller_state = Pid.Agent.get_state()

    UiWeb.Endpoint.broadcast("pid:control", "controller_updated", %{
      input: controller_state.last_input,
      output: controller_state.last_output
    })

    # I don't like this timer.
    Process.sleep(1000)

    update_ui(%{auto: controller_state.auto})
  end
end
