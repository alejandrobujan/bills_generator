defmodule BillsGenerator.Filters.LatexFormatter do
  alias BillsGenerator.Entities.BillRequest
  alias BillsGenerator.Core.GenFilter
  use GenFilter

  @impl GenFilter
  def worker_action(%{bill_id: bill_id, bill_request: bill_request}),
    do: %{bill_id: bill_id, bill_request: bill_request, latex: generate_latex(bill_request)}

  @impl GenFilter
  def next_action(output_data), do: BillsGenerator.Filters.LatexToPdf.process_filter(output_data)

  # Private functions

  @spec generate_latex(BillRequest.t()) :: String.t()
  defp generate_latex(bill_request) do
    """
    #{latex_styler(bill_request.config)}\\usepackage{longtable}\\usepackage{array}
    \\address{#{String.replace(bill_request.bill.seller, ",", ", \\\\ \n")}}
    \\begin{document}
    \\begin{letter}
    {#{String.replace(bill_request.bill.purchaser, ",", ", \\\\ \n")}}
    \\opening{}
    \\begin{center}
    \\renewcommand{\\arraystretch}{2}
    \\begin{longtable}{ p{3cm} p{3cm} p{3cm} p{3cm} p{3cm} }
    \\hline
    \\multicolumn{2}{>{\\centering}p{3cm}}{\\textbf{Product}} & \\multicolumn{1}{>{\\centering}p{3cm}}{\\textbf{Quantity}} & \\multicolumn{1}{>{\\centering}p{3cm}}{\\textbf{Price}} & \\multicolumn{1}{>{\\centering}p{3cm}}{\\textbf{Amount}} \\\\ \\hline
    """ <>
      format_bill(bill_request.bill.products, bill_request.bill.total) <>
      """
      \\end{longtable}
      \\renewcommand{\\arraystretch}{1}
      \\end{center}
      \\closing{Seal or signature:}
      \\end{letter}
      \\end{document}
      """
  end

  defp latex_styler(config) do
    "\\documentclass[#{config.paper_size}, #{config.font_size}pt#{landscape?(config.landscape)}#{font_styler(config.font_style)}"
  end

  defp font_styler("latex"), do: ""
  defp font_styler("times"), do: "\\usepackage{times}\n"

  defp landscape?(false), do: "]{letter}\n"
  defp landscape?(true), do: ", landscape]{letter}\n\\usepackage[margin=1cm]{geometry}\n"

  defp format_bill([], 0), do: ""

  defp format_bill(products, total) do
    do_format_bill("", products, total)
  end

  defp do_format_bill(acc, [], total) do
    acc <>
      """
      \\multicolumn{2}{c}{} & \\multicolumn{1}{c}{\\textbf{Dto.}} & \\multicolumn{1}{c}{XX\\%} & \\multicolumn{1}{c}{-5} \\\\ \\cline{3-5}
      \\multicolumn{2}{c}{} & \\multicolumn{1}{c}{\\textbf{IVA}} & \\multicolumn{1}{c}{XX\\%} & \\multicolumn{1}{c}{5} \\\\ \\cline{3-5}
      \\multicolumn{2}{c}{} & \\multicolumn{2}{c}{\\textbf{TOTAL}} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(total * 1.0, decimals: 2)}} \\\\ \\cline{3-5}
      """
  end

  defp do_format_bill(acc, [product | t], total) do
    do_format_bill(
      acc <>
        "\\multicolumn{2}{p{3cm}}{#{product.name}} & \\multicolumn{1}{>{\\centering}p{3cm}}{#{product.quantity}} & \\multicolumn{1}{>{\\centering}p{3cm}}{#{:erlang.float_to_binary(product.price * 1.0, decimals: 2)}} & \\multicolumn{1}{>{\\centering}p{3cm}}{#{:erlang.float_to_binary(product.total * 1.0, decimals: 2)}} \\\\ \\hline \n",
      t,
      total
    )
  end
end
