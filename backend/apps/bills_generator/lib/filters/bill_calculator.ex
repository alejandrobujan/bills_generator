defmodule BillsGenerator.Filters.BillCalculator do
  @moduledoc """
  Filtro que se encarga de calcular os totais dunha factura

  Redirixe a saída ao filtro `LatexFormatter`
  """
  alias BillsGenerator.Entities.{BillRequest, Bill}
  alias BillsGenerator.Core.GenFilter
  use GenFilter

  @impl GenFilter
  def worker_action(%{bill_id: bill_id, bill_request: bill_request}),
    do: %{bill_id: bill_id, bill_request: update_bill(bill_request)}

  @impl GenFilter
  def next_action(output_data),
    do: BillsGenerator.Filters.LatexFormatter.process_filter(output_data)

  # Private functions

  defp update_bill(bill_request) do
    updated_bill = Bill.update_total(bill_request.bill)
    %BillRequest{bill_request | bill: updated_bill}
  end
end
