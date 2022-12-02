defmodule BillsGenerator.Filters.StoreInDatabase do
  alias BillsGenerator.Core.StandardLeader
  alias BillsGenerator.Repository
  use StandardLeader

  @impl StandardLeader
  def worker_action({bill_id, bill_request, pdf}) do
    user = bill_request.user
    title = bill_request.bill.title

    Repository.Repo.get!(Repository.Bill, bill_id)
    |> Ecto.Changeset.change(user: user, title: title, pdf: pdf)
    |> Repository.Repo.update!()

    {:ok, bill_id, user}
  end

  # Handle error on leaders.
  @impl StandardLeader
  def next_action({:error, module, error_msg}),
    do: IO.puts("error in module #{module}: #{error_msg}")

  @impl StandardLeader
  def next_action({:ok, bill_id, user}),
    do: IO.puts("PDF for user #{user} with bill id #{bill_id} successfully generated")

  # Handle error on workers. It should insert a error condition into the databse
  @impl StandardLeader
  def on_error(module, error_msg),
    do:
      IO.puts(
        "catched error in #{__MODULE__.Worker}, error caused by module #{module}: #{error_msg}"
      )

  # Private functions
end
