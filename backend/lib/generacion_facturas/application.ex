defmodule GeneracionFacturas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Leaders.Leader1
  alias Leaders.Leader2

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: GeneracionFacturas.Worker.start_link(arg)
      # {GeneracionFacturas.Worker, arg}
      Leader1,
      Leader2
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GeneracionFacturas.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
