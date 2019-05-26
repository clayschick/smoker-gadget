defmodule Fw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]
  @target_env Mix.Project.config()[:target_env]

  use Application

  def start(_type, _args) do
    IO.inspect(Mix.Project.config())
    stop_fan(@target_env)
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  def children("host") do
    [
      Fw.Adapters.SpiTest,
      Fw.Temperature
    ]
  end

  def children(_target) do
    [
      Fw.Temperature
    ]
  end

  # PWM fans run when there is no voltage on the PWM pin
  # Need to stop the running fan when the app starts
  defp stop_fan("prod"), do: Fw.Fan.stop

  defp stop_fan(_), do: :ok
end
