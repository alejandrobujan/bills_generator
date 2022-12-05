defmodule BillsGenerator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias BillsGenerator.Filters.{
    BillParser,
    BillValidator,
    BillCalculator,
    LatexFormatter,
    LatexToPdf,
    StoreInDatabase
  }

  alias BillsGenerator.Repository.{Repo, BillDao}

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BillsGenerator.PubSub},
      # Start a worker by calling: BillsGenerator.Worker.start_link(arg)
      # {BillsGenerator.Worker, arg}
      BillParser,
      BillValidator,
      BillCalculator,
      LatexFormatter,
      LatexToPdf,
      StoreInDatabase
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BillsGenerator.Supervisor)
  end

  def generate_bill(json_bill) do
    # Esto lo debería hacer un filtro?
    {:ok, stored_bill} = Repo.insert(%BillDao{})
    bill_id = stored_bill.id
    BillParser.process_filter(bill_id: bill_id, json_bill: json_bill)
    # We have to return bill_id in order to let client which bill is generating
    bill_id
  end
end
