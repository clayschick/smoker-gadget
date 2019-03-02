defmodule Fw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
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
end
