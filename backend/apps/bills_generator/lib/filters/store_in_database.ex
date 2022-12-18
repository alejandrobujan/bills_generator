defmodule BillsGenerator.Filters.StoreInDatabase do
  @moduledoc """
  Filtro que se encarga de gardar a factura nunha base de datos.

  En caso de que se producira algún error nunha etapa anterior do pipeline, garda o erro na base de datos.


  Non redirixe a súa saída a ningún outro filtro.
  """
  alias BillsGenerator.Core.GenFilter
  alias BillsGenerator.Repository.{Repo, BillDao}
  use GenFilter

  @impl GenFilter
  def worker_action(%{bill_id: bill_id, bill_request: bill_request, pdf: pdf}) do
    user = bill_request.user
    title = bill_request.bill.title

    Repo.get!(BillDao, bill_id)
    |> Ecto.Changeset.change(user: user, title: title, pdf: pdf, error: false)
    |> Repo.update!()

    %{bill_id: bill_id, user: user}
  end

  # Handle error on leaders. This could be useful for loggin errors
  @impl GenFilter
  def next_action({:error, module, error_msg, _input_data}),
    do: Logger.info("error in module #{module}: #{error_msg}")

  @impl GenFilter
  def next_action(%{bill_id: bill_id, user: user}),
    do: Logger.info("PDF for user #{user} with bill id #{bill_id} successfully generated")

  # We use a map for input_data, so we can catch any input_data that has
  # at least the bill_id field. This helps us to catch errors from any
  # filter, since their input data contains at least the bill_id field.

  @impl GenFilter
  def on_error(caused_by, error_msg, %{bill_id: bill_id}) do
    Logger.info(
      "catched error in #{__MODULE__.Worker}, error caused by filter #{caused_by}: #{error_msg}"
    )

    Repo.get!(BillDao, bill_id)
    |> Ecto.Changeset.change(error: true, error_msg: error_msg)
    |> Repo.update!()
  end
end
