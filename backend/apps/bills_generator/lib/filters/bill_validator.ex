defmodule BillsGenerator.Filters.BillValidator do
  alias BillsGenerator.Entities.BillRequest
  alias BillsGenerator.Core.GenFilter
  use GenFilter

  @impl GenFilter
  def worker_action(%{bill_id: _bill_id, bill_request: bill_request} = input_data) do
    validate_request!(bill_request)
    input_data
  end

  @impl GenFilter
  def next_action(output_data),
    do: BillsGenerator.Filters.BillCalculator.process_filter(output_data)

  # Private functions

  defp validate_request!(bill_request) do
    case BillRequest.validate(bill_request) do
      :ok -> :ok
      {:error, reason} -> raise reason
    end
  end
end
