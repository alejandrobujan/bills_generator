defmodule BillsGenerator.Filters.BillParser do
  alias BillsGenerator.Entities.{BillRequest, Bill, BillConfig, Product}
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({bill_id, json_bill}),
    do: {bill_id, parse_json(json_bill)}

  @impl StandardLeader
  def next_action(output_data),
    do: BillsGenerator.Filters.BillValidator.process_filter(output_data)

  # Private functions

  defp parse_json(json_bill) do
    Poison.decode!(json_bill,
      as: %BillRequest{
        bill: %Bill{products: [%Product{}]},
        config: %BillConfig{}
      }
    )
  end
end
