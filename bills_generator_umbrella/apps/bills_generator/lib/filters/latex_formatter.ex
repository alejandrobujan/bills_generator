defmodule BillsGenerator.Filters.LatexFormatter do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({stored_bill, bill, seller, purchaser}),
    do: {stored_bill, generate_latex(bill, seller, purchaser)}

  @impl StandardLeader
  def next_action(output_data), do: BillsGenerator.Filters.LatexToPdf.process_filter(output_data)

  # Private functions

  defp generate_latex(bill, seller, purchaser) do
    "\\documentclass[a4paper, 10pt]{letter}\n\\address{#{String.replace(seller, ",", ", \\\\ \n")}}\n\\begin{document}\n\\begin{letter}\n{#{String.replace(purchaser, ",", ", \\\\ \n")}}\n\\opening{}\n\\begin{center}\n\\begin{tabular}{| p{7cm} | l | l | l |}\n\\hline\nDescription & Quantity & Price & Amount \\\\ \\hline \n" <>
      format_bill(bill) <>
      "\\end{tabular}\n\\end{center}\n\\closing{Seal or signature:}\n\\end{letter}\n\\end{document}"
  end

  defp format_bill([]), do: ""

  defp format_bill({bill_lines, total}) do
    do_format_bill("", Enum.reverse(bill_lines), total)
  end

  defp do_format_bill(acc, [], total) do
    acc <>
      "\\multicolumn{3}{|c|}{TOTAL} & #{:erlang.float_to_binary(total, decimals: 2)} \\\\ \\hline\n"
  end

  defp do_format_bill(acc, [{{product, qty}, amount} | t], total) do
    do_format_bill(
      acc <>
        "#{product.name} & #{qty} & #{:erlang.float_to_binary(product.price, decimals: 2)} & #{:erlang.float_to_binary(amount, decimals: 2)} \\\\ \\hline \n",
      t,
      total
    )
  end
end
