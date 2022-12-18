defmodule BillsGenerator.Filters.LatexFormatter do
  @moduledoc """
  Filtro que se encarga de formatear a petición de factura, pasando de unha estructura de datos interna (`BillRequest`)
  a unha cadea de texto en formato LaTeX.

  Redirixe a saída ao filtro `LatexToPdf`
  """

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
    #{latex_styler(bill_request.config)}\\usepackage{longtable}\\usepackage{array}\\usepackage{eurosym}
    \\date{#{Calendar.strftime(Date.from_iso8601!(bill_request.bill.date), "%d/%m/%Y")}}
    \\newcommand{\\currency}{#{currency_symbol(bill_request.config.currency)}}
    \\address{#{Resources.get_global_resources(bill_request.config.language).seller}: \\\\ \n #{String.replace(bill_request.bill.seller, ",", ", \\\\ \n")}}
    \\begin{document}
    \\begin{letter}
    {#{Resources.get_global_resources(bill_request.config.language).purchaser}: \\\\ \n #{String.replace(bill_request.bill.purchaser, ",", ", \\\\ \n")}}
    \\opening{}
    \\begin{center}
    \\renewcommand{\\arraystretch}{2}
    \\begin{longtable}{@{\\extracolsep{\\fill}} c c c c c }
    \\hline
    \\multicolumn{1}{c}{\\textbf{#{Resources.get_global_resources(bill_request.config.language).product}}} & \\multicolumn{1}{c}{\\textbf{#{Resources.get_global_resources(bill_request.config.language).quantity}}} & \\multicolumn{1}{c}{\\textbf{#{Resources.get_global_resources(bill_request.config.language).price}}} & \\multicolumn{1}{c}{\\textbf{#{Resources.get_global_resources(bill_request.config.language).discount}}} & \\multicolumn{1}{c}{\\textbf{#{Resources.get_global_resources(bill_request.config.language).amount}}} \\\\ \\hline
    """ <>
      format_bill(
        bill_request.bill.products,
        bill_request.bill.total_before_taxes,
        bill_request.bill.taxes,
        bill_request.bill.taxes_amount,
        bill_request.bill.total,
        bill_request.config.language
      ) <>
      """
      \\end{longtable}
      \\renewcommand{\\arraystretch}{1}
      \\end{center}
      \\closing{#{Resources.get_global_resources(bill_request.config.language).sealorsignature}:}
      \\end{letter}
      \\end{document}
      """
  end

  defp latex_styler(config) do
    """
    \\documentclass[#{config.paper_size}, #{config.font_size}pt#{landscape?(config.landscape)}#{font_styler(config.font_style)}
    """
  end

  defp font_styler("latex"), do: ""
  defp font_styler("times"), do: "\\usepackage{times}\n"

  defp landscape?(false), do: "]{letter}\n"
  defp landscape?(true), do: ", landscape]{letter}\n\\usepackage[margin=1cm]{geometry}\n"

  defp currency_symbol("euro"), do: "\\euro"
  defp currency_symbol("dollar"), do: "\\$"

  defp format_bill([], _total_before_taxes, _taxes, _taxes_amount, 0, _language), do: ""

  defp format_bill(products, total_before_taxes, taxes, taxes_amount, total, language) do
    do_format_bill("", products, total_before_taxes, taxes, taxes_amount, total, language)
  end

  defp do_format_bill(acc, [], total_before_taxes, taxes, taxes_amount, total, language) do
    acc <>
      """
      \\multicolumn{2}{c}{} & \\multicolumn{1}{r}{\\textbf{#{Resources.get_global_resources(language).total_before_taxes}}} && \\multicolumn{1}{c}{#{:erlang.float_to_binary(total_before_taxes * 1.0, decimals: 2)} \\currency} \\\\
      \\multicolumn{2}{c}{} & \\multicolumn{1}{r}{\\textbf{#{Resources.get_global_resources(language).taxes}}} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(taxes * 1.0, decimals: 2)} \\%} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(taxes_amount * 1.0, decimals: 2)} \\currency} \\\\ \\cline{3-5}
      \\multicolumn{2}{c}{} & \\multicolumn{1}{r}{\\textbf{#{String.upcase(Resources.get_global_resources(language).total)}}} && \\multicolumn{1}{c}{#{:erlang.float_to_binary(total * 1.0, decimals: 2)} \\currency} \\\\
      """
  end

  defp do_format_bill(
         acc,
         [%{discounted_amount: 0.0} = product | t],
         total_before_taxes,
         taxes,
         taxes_amount,
         total,
         language
       ) do
    do_format_bill(
      acc <>
        "\\multicolumn{1}{c}{#{product.name}} & \\multicolumn{1}{c}{#{product.quantity}} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(product.price * 1.0, decimals: 2)} \\currency} & \\multicolumn{1}{c}{-} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(product.total * 1.0, decimals: 2)} \\currency} \\\\ \\hline \n",
      t,
      total_before_taxes,
      taxes,
      taxes_amount,
      total,
      language
    )
  end

  defp do_format_bill(
         acc,
         [product | t],
         total_before_taxes,
         taxes,
         taxes_amount,
         total,
         language
       ) do
    do_format_bill(
      acc <>
        "\\multicolumn{1}{c}{#{product.name}} & \\multicolumn{1}{c}{#{product.quantity}} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(product.price * 1.0, decimals: 2)} \\currency} & \\multicolumn{1}{c}{-#{:erlang.float_to_binary(product.discounted_amount * 1.0, decimals: 2)} \\currency} & \\multicolumn{1}{c}{#{:erlang.float_to_binary(product.total * 1.0, decimals: 2)} \\currency} \\\\ \\hline \n",
      t,
      total_before_taxes,
      taxes,
      taxes_amount,
      total,
      language
    )
  end
end
