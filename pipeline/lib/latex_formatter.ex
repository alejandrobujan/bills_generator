defmodule LaTeXFormatter do
  @moduledoc """
  Filtro encargado de formatear e embeber a factura xa calculada en código LaTeX.
  Implementado con `GenServer` para poder supervisalo.
  """

  use GenServer
  require Logger

  @doc """
  Inicia o filtro formateador de código LaTeX.
  ## Exemplos:
    iex> LaTeXFormatter.start_link([])\n
    iex> Process.whereis(LaTeXFormatter) |> Process.alive?\n
    true\n
    iex> LaTeXFormatter.stop()\n
  """
  @spec start_link(list) :: {:ok, pid()}
  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Para o filtro formateador de código LaTeX.
  ## Exemplos:
     iex> LaTeXFormatter.start_link([])\n
     iex> LaTeXFormatter.stop()\n
     iex> Process.whereis(LaTeXFormatter)\n
     nil\n
  """
  @spec stop() :: :ok
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Encárgase de formatear e embeber o comprador, vendedor, e liñas da factura e estructuralizalas no documento, e enviar a saída á entrada do seguinte filtro.
  ## Exemplos:
     iex> LaTeXFormatter.start_link([])\n
     iex> LaTeXFormatter.format({[], 0.00}, "Alejandro", "Sandra")\n
     "{:ok, :ok}"\n
     iex> LaTeXFormatter.stop()\n
  """
  @spec format(BillRequest.t()) :: {:ok, :ok}
  def format(bill_request) do
    {:ok, GenServer.cast(__MODULE__, {:format, bill_request})}
  end

  @doc """
  Función específica encargada de formatear e embeber o comprador, vendedor, e liñas da factura e estructuralizalas nun documento LaTeX. Devolve o código fonte.
  ## Exemplos:
     iex> seller = "Sainsbury's, 15-17 Tottenham Ct Rd, London W1T 1BJ, UK"\n
     "Sainsbury's, 15-17 Tottenham Ct Rd, London W1T 1BJ, UK"\n
     iex> purchaser = "John Smith, 7 Horsefair Green, Otterbourne SO21 1GN, UK"\n
     "John Smith, 7 Horsefair Green, Otterbourne SO21 1GN, UK"\n
     iex> bill = {[{{%Product{name: "Peas", price: 1.0}, 1}, 1.0}, {{%Product{name: "Pizza", price: 2.8}, 3}, 8.399999999999999}, {{%Product{name: "Ice Cream", price: 5.0}, 1}, 5.0}, {{%Product{name: "Tomato Sauce", price: 1.2}, 2}, 2.4}, {{%Product{name: "Rice", price: 1.0}, 2}, 2.0}], 18.799999999999997}\n
     {[{{%Product{name: "Peas", price: 1.0}, 1}, 1.0}, {{%Product{name: "Pizza", price: 2.8}, 3}, 8.399999999999999}, {{%Product{name: "Ice Cream", price: 5.0}, 1}, 5.0}, {{%Product{name: "Tomato Sauce", price: 1.2}, 2}, 2.4}, {{%Product{name: "Rice", price: 1.0}, 2}, 2.0}], 18.799999999999997}\n
     iex> LaTeXFormatter.generate_latex(bill, seller, purchaser)\n
     "\\documentclass[a4paper, 10pt]{letter}\n\\address{Sainsbury's, \\\\ \n 15-17 Tottenham Ct Rd, \\\\ \n London W1T 1BJ, \\\\ \n UK}\n\\begin{document}\n\\begin{letter}\n{John Smith, \\\\ \n 7 Horsefair Green, \\\\ \n Otterbourne SO21 1GN, \\\\ \n UK}\n\\opening{}\n\\begin{center}\n\\begin{tabular}{| p{7cm} | l | l | l |}\n\\hline\nDescription & Quantity & Price & Amount \\\\ \\hline \nRice & 2 & 1.00 & 2.00 \\\\ \\hline \nTomato Sauce & 2 & 1.20 & 2.40 \\\\ \\hline \nIce Cream & 1 & 5.00 & 5.00 \\\\ \\hline \nPizza & 3 & 2.80 & 8.40 \\\\ \\hline \nPeas & 1 & 1.00 & 1.00 \\\\ \\hline \n\\multicolumn{3}{|c|}{TOTAL} & 18.80 \\\\ \\hline\n\\end{tabular}\n\\end{center}\n\\closing{Seal or signature:}\n\\end{letter}\n\\end{document}"\n
  """
  @spec generate_latex(BillRequest.t()) :: String.t()
  def generate_latex(bill_request) do
    "#{latex_styler(bill_request.config)}\\address{#{String.replace(bill_request.bill.seller, ",", ", \\\\ \n")}}\n\\begin{document}\n\\begin{letter}\n{#{String.replace(bill_request.bill.purchaser, ",", ", \\\\ \n")}}\n\\opening{}\n\\begin{center}\n\\begin{tabular}{| p{7cm} | l | l | l |}\n\\hline\nDescription & Quantity & Price & Amount \\\\ \\hline \n" <> format_bill(bill_request.bill.lines, bill_request.bill.total) <> "\\end{tabular}\n\\end{center}\n\\closing{Seal or signature:}\n\\end{letter}\n\\end{document}"
  end

  def latex_styler(config) do
    "\\documentclass[#{config.paper_size}, #{config.font_size}#{landscape?(config.landscape)}#{font_styler(config.font_style)}"
  end

  def font_styler("latex"), do: ""
  def font_styler("times"), do: "\\usepackage{times}\n"

  def landscape?(false), do: "]{letter}\n"
  def landscape?(true), do: ", landscape]{letter}\n\\usepackage[margin=1cm]{geometry}\n"

  # GenServer callbacks

  @impl true
  def init(_init_arg) do
    Logger.info("[LaTeXFormatter] GenServer LaTeXFormatter initialized")
    {:ok, []}
  end

  @impl true
  def handle_cast({:format, bill_request}, data) do
    latex = generate_latex(bill_request)
    Logger.info("[LaTeXFormatter] Piped to LaTeXToPdf filter")
    LaTeXToPdf.generate(bill_request.user, latex)
    {:noreply, [latex | data]}
  end

  # Private functions

  defp format_bill([], 0), do: ""
  defp format_bill(lines, total) do
    do_format_bill("", Enum.reverse(lines), total)
  end

  defp do_format_bill(acc, [], total) do
    acc <> "\\multicolumn{3}{|c|}{TOTAL} & #{:erlang.float_to_binary(total*1.0, [decimals: 2])} \\\\ \\hline\n"
  end

  defp do_format_bill(acc, [line | t], total) do
    do_format_bill(acc <> "#{line.product.name} & #{line.quantity} & #{:erlang.float_to_binary(line.product.price*1.0, [decimals: 2])} & #{:erlang.float_to_binary(line.price*1.0, [decimals: 2])} \\\\ \\hline \n", t, total)
  end

end
