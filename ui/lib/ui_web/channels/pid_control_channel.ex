defmodule UiWeb.PidControlChannel do
  use Phoenix.Channel

  def join("pid:control", _message, socket) do
    # send(self, {:output, 0.0})
    {:ok, socket}
  end

  def handle_in("setpoint_update", %{"setpoint" => setpoint}, socket) do
    :ok = Pid.Agent.update(setpoint: String.to_integer(setpoint))

    # push(socket, "setpoint_updated", %{setpoint: setpoint})

    {:noreply, socket}
  end

  def handle_in("kp_update", %{"kp" => kp}, socket) do
    :ok = Pid.Agent.update(kp: String.to_float(kp))

    {:noreply, socket}
  end

  def handle_in("ki_update", %{"ki" => ki}, socket) do
    :ok = Pid.Agent.update(ki: String.to_float(ki))

    {:noreply, socket}
  end

  def handle_in("kd_update", %{"kd" => kd}, socket) do
    :ok = Pid.Agent.update(kd: String.to_float(kd))

    {:noreply, socket}
  end

  def handle_in("start_controller", attrs, socket) do
    :ok = Ui.PidControl.start(attrs)

    {:noreply, socket}
  end

  def handle_in("stop_controller", _attrs, socket) do
    :ok = Ui.PidControl.stop()

    {:noreply, socket}
  end

  def handle_in("send_updates", {}, socket) do
    controller_state = Pid.Agent.get_state()

    push(socket, "controller_updated", %{
      input: controller_state.last_input,
      output: controller_state.last_output
    })

    {:noreply, socket}
  end
end
