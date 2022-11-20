defmodule BillsGenerator.Filters.BillCalculator do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({stored_bill, bill_lines, seller, purchaser}),
    do: {stored_bill, calculate_bill(bill_lines), seller, purchaser}

  @impl StandardLeader
  def next_action(output_data),
    do: BillsGenerator.Filters.LatexFormatter.process_filter(output_data)

  # Private functions

  defp calculate_bill([]), do: []

  defp calculate_bill(bill_lines), do: do_calculate_bill([], bill_lines, 0)

  defp do_calculate_bill(acc, [], total), do: {acc, total}

  defp do_calculate_bill(acc, [pair = {product, qty} | t], total) do
    do_calculate_bill([{pair, product.price * qty} | acc], t, total + product.price * qty)
  end
end
