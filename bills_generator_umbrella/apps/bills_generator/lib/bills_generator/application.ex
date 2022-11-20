defmodule BillsGenerator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias BillsGenerator.Filters.BillCalculator
  alias BillsGenerator.Filters.LatexFormatter
  alias BillsGenerator.Filters.LatexToPdf

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BillsGenerator.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BillsGenerator.PubSub},
      # Start a worker by calling: BillsGenerator.Worker.start_link(arg)
      # {BillsGenerator.Worker, arg}
      BillCalculator,
      LatexFormatter,
      LatexToPdf
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BillsGenerator.Supervisor)
  end

  def generate_bill(user, products, seller, purchaser) do
    # Esto lo debería hacer un filtro?
    {:ok, stored_bill} = Repo.insert(%Bill{user: user})

    BillCalculator.process_filter({stored_bill, products, seller, purchaser})
  end
end
