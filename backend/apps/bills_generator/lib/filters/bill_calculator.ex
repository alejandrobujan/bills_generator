defmodule BillsGenerator.Filters.BillCalculator do
  alias BillsGenerator.Entities.{BillRequest, Bill, Product}
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action(bill_id: bill_id, bill_request: bill_request),
    do: [bill_id: bill_id, bill_request: update_bill(bill_request)]

  @impl StandardLeader
  def next_action(output_data),
    do: BillsGenerator.Filters.LatexFormatter.process_filter(output_data)

  # Private functions

  defp update_bill(bill_request) do
    {updated_bill_products, total} = calculate_bill(bill_request.bill.products)
    updated_bill = %Bill{bill_request.bill | products: updated_bill_products, total: total}
    %BillRequest{bill_request | bill: updated_bill}
  end

  defp calculate_bill([]), do: {[], 0}

  defp calculate_bill(products), do: do_calculate_bill([], products, 0)

  defp do_calculate_bill(acc, [], total), do: {acc, total}

  defp do_calculate_bill(acc, [product = %Product{price: price, quantity: qty} | t], total) do
    product_total_price = price * qty

    do_calculate_bill(
      [%Product{product | total: product_total_price} | acc],
      t,
      total + product_total_price
    )
  end
end
