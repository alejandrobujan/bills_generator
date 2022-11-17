defmodule Duxir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Core.Leader
  alias Services.Service1
  alias Services.Service2

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Duxir.Worker.start_link(arg)
      {Leader, [service_1: {Service1, 3}, service_2: {Service2, 1}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Duxir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
