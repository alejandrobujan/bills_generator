defmodule BillsGenerator.Filters.StoreInDatabase do
  alias BillsGenerator.Core.StandardLeader
  alias BillsGenerator.Repository
  use StandardLeader

  @impl StandardLeader
  def worker_action(bill_id: bill_id, bill_request: bill_request, pdf: pdf) do
    user = bill_request.user
    title = bill_request.bill.title

    Repository.Repo.get!(Repository.Bill, bill_id)
    |> Ecto.Changeset.change(user: user, title: title, pdf: pdf, error: false)
    |> Repository.Repo.update!()

    [bill_id: bill_id, user: user]
  end

  # Handle error on leaders. This could be useful for loggin errors
  @impl StandardLeader
  def next_action({:error, module, error_msg, _input_data}),
    do: Logger.error("error in module #{module}: #{error_msg}")

  @impl StandardLeader
  def next_action(bill_id: bill_id, user: user),
    do: Logger.info("PDF for user #{user} with bill id #{bill_id} successfully generated")

  # This matches a bill that has been successfully parsed by the BillParser
  # filter. We need to do this because if the error happens in the BillParser,
  # we can't have information about the user and title.
  @impl StandardLeader
  def on_error(module, error_msg, bill_id: bill_id, bill_request: bill_request) do
    Logger.error(
      "catched error in #{__MODULE__.Worker}, error caused by filter #{module}: #{error_msg}"
    )

    user = bill_request.user
    title = bill_request.bill.title

    Repository.Repo.get!(Repository.Bill, bill_id)
    |> Ecto.Changeset.change(user: user, title: title, error: true, error_msg: error_msg)
    |> Repository.Repo.update!()
  end

  # Catch errors that happens in the BillParser filter. The input data at that filter
  # is the bill id and the json bill. We can't know the user since an error happened in the
  # parse, so we only have the bill_id.
  # Is there a better way of pattern matching the keyword list than this?
  def on_error(module, error_msg, [bill_id: bill_id] ++ _rest) do
    # bills that have not been parsed yet have the user and title fields empty
    # so they should be queried only by id
    Logger.error(
      "catched error in #{__MODULE__.Worker}, error caused by filter #{module}: #{error_msg}"
    )

    Repository.Repo.get!(Repository.Bill, bill_id)
    |> Ecto.Changeset.change(error: true, error_msg: error_msg)
    |> Repository.Repo.update!()
  end
end
