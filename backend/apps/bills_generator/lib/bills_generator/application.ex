defmodule BillsGenerator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias BillsGenerator.Filters.{BillCalculator, LatexFormatter, LatexToPdf, StoreInDatabase}
  alias BillsGenerator.{Bill, Repo}

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
      LatexToPdf,
      StoreInDatabase
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BillsGenerator.Supervisor)
  end

  def generate_bill(title, user, products, seller, purchaser) do
    # Esto lo debería hacer un filtro?
    {:ok, stored_bill} = Repo.insert(%Bill{})

    bill_id = stored_bill.id

    BillCalculator.process_filter({bill_id, title, user, products, seller, purchaser})
    bill_id
  end
end
