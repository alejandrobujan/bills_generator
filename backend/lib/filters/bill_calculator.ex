defmodule Filters.BillCalculator do
  alias Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({bill_lines, seller, purchaser}),
    do: {calculate_bill(bill_lines), seller, purchaser}

  @impl StandardLeader
  def next_action(output_data), do: Filters.LatexFormatter.process_filter(output_data)

  # Private functions

  defp calculate_bill([]), do: []

  defp calculate_bill(bill_lines), do: do_calculate_bill([], bill_lines, 0)

  defp do_calculate_bill(acc, [], total), do: {acc, total}

  defp do_calculate_bill(acc, [pair = {product, qty} | t], total) do
    do_calculate_bill([{pair, product.price * qty} | acc], t, total + product.price * qty)
  end
end
