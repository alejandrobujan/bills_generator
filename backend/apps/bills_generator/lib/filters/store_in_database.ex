defmodule BillsGenerator.Filters.StoreInDatabase do
  alias BillsGenerator.Core.StandardLeader
  alias BillsGenerator.{Repo, Bill}
  use StandardLeader

  @impl StandardLeader
  def worker_action({bill_id, title, user, pdf}) do
    Repo.get!(Bill, bill_id)
    |> Ecto.Changeset.change(user: user, title: title, pdf: pdf)
    |> BillsGenerator.Repo.update!()

    {:ok, bill_id, user}
  end

  # Handle error on leaders.
  @impl StandardLeader
  def next_action({:error, error_msg}), do: IO.puts("error in leader: #{error_msg}")

  @impl StandardLeader
  def next_action({:ok, bill_id, user}),
    do: IO.puts("PDF for user #{user} with bill id #{bill_id} successfully generated")

  # Handle error on workers. It should insert a error condition into the databse
  @impl StandardLeader
  def on_error(error_msg), do: IO.puts("error in worker: #{error_msg}")
  # Private functions
end
