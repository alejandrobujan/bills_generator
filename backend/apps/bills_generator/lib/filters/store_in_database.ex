defmodule BillsGenerator.Filters.StoreInDatabase do
  alias BillsGenerator.Core.GenFilter
  alias BillsGenerator.Repository
  use GenFilter

  @impl GenFilter
  def worker_action(bill_id: bill_id, bill_request: bill_request, pdf: pdf) do
    user = bill_request.user
    title = bill_request.bill.title

    Repository.Repo.get!(Repository.Bill, bill_id)
    |> Ecto.Changeset.change(user: user, title: title, pdf: pdf, error: false)
    |> Repository.Repo.update!()

    [bill_id: bill_id, user: user]
  end

  # Handle error on leaders. This could be useful for loggin errors
  @impl GenFilter
  def next_action({:error, module, error_msg, _input_data}),
    do: Logger.error("error in module #{module}: #{error_msg}")

  @impl GenFilter
  def next_action(bill_id: bill_id, user: user),
    do: Logger.info("PDF for user #{user} with bill id #{bill_id} successfully generated")

  # All filters has a bill_id field in the input_data keyword, so we can
  # access it if error happens in any filter.
  # We could get the input_data of bill_validator, and it would contain
  # the user & title, but we don't know for sure that that user & title
  # would be valid. In filters latex_to_pdf and latex_formatter, we know
  # that these 2 fields are valid, but if an error happens in those
  # modules, it is not relevant to the user generating the bill.
  def on_error(caused_by, error_msg, [bill_id: bill_id] ++ _rest) do
    Logger.error(
      "catched error in #{__MODULE__.Worker}, error caused by filter #{caused_by}: #{error_msg}"
    )

    Repository.Repo.get!(Repository.Bill, bill_id)
    |> Ecto.Changeset.change(error: true, error_msg: error_msg)
    |> Repository.Repo.update!()
  end
end
