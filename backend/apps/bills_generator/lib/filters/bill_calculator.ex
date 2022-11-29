defmodule BillsGenerator.Filters.BillCalculator do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({bill_id, title, user, bill_lines, seller, purchaser}),
    do: {bill_id, title, user, calculate_bill(bill_lines), seller, purchaser}

  # Example of error
  # @impl StandardLeader
  # def worker_action({stored_bill, bill_lines, seller, purchaser}) do
  #   raise "error on bill_calculator"
  # end

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
