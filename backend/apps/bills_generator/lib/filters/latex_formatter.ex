defmodule BillsGenerator.Filters.LatexFormatter do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  # Example of error
  # @impl StandardLeader
  # def worker_action({stored_bill, bill_lines, seller, purchaser}) do
  #   raise "error on LatexFormatter"
  # end
  @impl StandardLeader
  def worker_action({bill_id, bill_request}),
    do: {bill_id, bill_request, generate_latex(bill_request)}

  @impl StandardLeader
  def next_action(output_data), do: BillsGenerator.Filters.LatexToPdf.process_filter(output_data)

  # Private functions

  @spec generate_latex(BillRequest.t()) :: String.t()
  def generate_latex(bill_request) do
    "#{latex_styler(bill_request.config)}\\usepackage{longtable}\n\\address{#{String.replace(bill_request.bill.seller, ",", ", \\\\ \n")}}\n\\begin{document}\n\\begin{letter}\n{#{String.replace(bill_request.bill.purchaser, ",", ", \\\\ \n")}}\n\\opening{}\n\\begin{center}\n\\begin{longtable}{| p{7cm} | l | l | l |}\n\\hline\nDescription & Quantity & Price & Amount \\\\ \\hline \n" <>
      format_bill(bill_request.bill.products, bill_request.bill.total) <>
      "\\end{longtable}\n\\end{center}\n\\closing{Seal or signature:}\n\\end{letter}\n\\end{document}"
  end

  def latex_styler(config) do
    "\\documentclass[#{config.paper_size}, #{config.font_size}pt#{landscape?(config.landscape)}#{font_styler(config.font_style)}"
  end

  def font_styler("latex"), do: ""
  def font_styler("times"), do: "\\usepackage{times}\n"

  def landscape?(false), do: "]{letter}\n"
  def landscape?(true), do: ", landscape]{letter}\n\\usepackage[margin=1cm]{geometry}\n"

  defp format_bill([], 0), do: ""

  defp format_bill(products, total) do
    do_format_bill("", Enum.reverse(products), total)
  end

  defp do_format_bill(acc, [], total) do
    acc <>
      "\\multicolumn{3}{|c|}{TOTAL} & #{:erlang.float_to_binary(total * 1.0, decimals: 2)} \\\\ \\hline\n"
  end

  defp do_format_bill(acc, [product | t], total) do
    do_format_bill(
      acc <>
        "#{product.name} & #{product.quantity} & #{:erlang.float_to_binary(product.price * 1.0, decimals: 2)} & #{:erlang.float_to_binary(product.total * 1.0, decimals: 2)} \\\\ \\hline \n",
      t,
      total
    )
  end
end
