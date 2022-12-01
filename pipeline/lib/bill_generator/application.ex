defmodule BillGenerator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type \\ :default, _args \\ []) do
    children = [
      # Starts a worker by calling: BillGenerator.Worker.start_link(arg)
      # {BillGenerator.Worker, arg}
      {JSONParser, []},
      {BillCalculator, []},
      {LaTeXFormatter, []},
      {LaTeXToPdf, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BillGenerator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def generate(json_bill) do
    Logger.info("[BillGenerator] Piped to JSONParser filter")
    JSONParser.parse(json_bill)  end
end
