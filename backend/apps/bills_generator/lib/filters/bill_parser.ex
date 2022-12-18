defmodule BillsGenerator.Filters.BillParser do
  @moduledoc """
  Filtro que se encarga de parsear a petición de factura, pasando dun formato en JSON como entrada,
  a unha estructura de datos interna (`BillRequest`).
  
  Redirixe a saída ao filtro `BillValidator`
  """
  alias BillsGenerator.Entities.{BillRequest, Bill, BillConfig, Product}
  alias BillsGenerator.Core.GenFilter
  use GenFilter

  @impl GenFilter
  def worker_action(%{bill_id: bill_id, json_bill: json_bill}),
    do: %{bill_id: bill_id, bill_request: parse_json(json_bill)}

  @impl GenFilter
  def next_action(output_data),
    do: BillsGenerator.Filters.BillValidator.process_filter(output_data)

  # Private functions

  @spec parse_json(String.t()) :: BillRequest.t()
  defp parse_json(json_bill) do
    Poison.decode!(json_bill,
      as: %BillRequest{
        bill: %Bill{products: [%Product{}]},
        config: %BillConfig{}
      }
    )
  end
end
