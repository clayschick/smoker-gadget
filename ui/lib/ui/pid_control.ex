defmodule Ui.PidControl do
  @moduledoc """
  Starts and stops the Tasks that will run the controller
  and the update to the UI.
  """

  @doc """
  Starts a Task with the controller function and a Task
  that starts a ui refresh/update function.

  The attrs argument is coming from the controller form
  in the UI and is submitted by the user. I don't have a
  fancy web front-end framework to use for form validation
  and I don't want to use the ol' alert box. So I'm checking
  for an :error and setting the value to 0 or 0.0.
  """
  def start(setpoint, kp, ki, kd) do
    Pid.Agent.update(
      auto: true,
      setpoint: setpoint,
      kp: kp,
      ki: ki,
      kd: kd
    )

    # If this function returned the last_input and last_ouput
    # on every cycle then I could use it to push up to the UI
    # This links to the current process but do I really care?
    {:ok, _} = Task.start(fn -> Pid.Controller.run() end)

    {:ok, _} = Task.start(fn -> update_ui(%{auto: true}) end)

    :ok
  end

  def start_stream(setpoint, kp, ki, kd) do
    Pid.Agent.update(
      auto: true,
      setpoint: setpoint,
      kp: kp,
      ki: ki,
      kd: kd
    )
    {:ok, _} = Task.start(fn -> update_ui_stream() end)
  end

  def update_ui_stream() do
    Pid.Controller.eval_stream()
    |> Stream.map(fn {:ok, %{input: input, output: output}} ->
      UiWeb.Endpoint.broadcast("pid:control", "controller_updated", %{
        input: input,
        output: output
      })
    end)
    |> Stream.take_while(fn _ -> Pid.Agent.is_auto?() end)
    |> Stream.run()
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
