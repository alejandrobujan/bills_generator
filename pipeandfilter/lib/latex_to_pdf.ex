defmodule LaTeXToPdf do
  @moduledoc """
  Filtro encargado da xestión da compilación do código LaTeX e da xeración e exportación do documento en formato PDF.
  Implementado con `GenServer` para poder supervisalo.
  """
  use GenServer
  require Logger

  @doc """
  Inicia o filtro xestor da compilación.
  ## Exemplos:
    iex> LaTeXToPdf.start_link([])\n
    iex> Process.whereis(LaTeXToPdf) |> Process.alive?\n
    true\n
    iex> LaTeXToPdf.stop()\n
  """
  @spec start_link(list) :: {:ok, pid()}
  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Para o filtro xestor da compilación.
  ## Exemplos:
     iex> LaTeXToPdf.start_link([])\n
     iex> LaTeXToPdf.stop()\n
     iex> Process.whereis(LaTeXToPdf)\n
     nil\n
  """
  @spec stop() :: :ok
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Recibe o código LaTeX e calcula o nome do ficheiro en base á data e hora actual. Compila o código e xera o documento con ese nome no directorio out/
  ## Exemplos:
     iex> LaTeXToPdf.start_link([])\n
     iex> LaTeXToPdf.generate("\\documentclass[a4paper, 10pt]{letter}\n\\address{Sainsbury's, \\\\ \n 15-17 Tottenham Ct Rd, \\\\ \n London W1T 1BJ, \\\\ \n UK}\n\\begin{document}\n\\begin{letter}\n{John Smith, \\\\ \n 7 Horsefair Green, \\\\ \n Otterbourne SO21 1GN, \\\\ \n UK}\n\\opening{}\n\\begin{center}\n\\begin{tabular}{| p{7cm} | l | l | l |}\n\\hline\nDescription & Quantity & Price & Amount \\\\ \\hline \nRice & 2 & 1.00 & 2.00 \\\\ \\hline \nTomato Sauce & 2 & 1.20 & 2.40 \\\\ \\hline \nIce Cream & 1 & 5.00 & 5.00 \\\\ \\hline \nPizza & 3 & 2.80 & 8.40 \\\\ \\hline \nPeas & 1 & 1.00 & 1.00 \\\\ \\hline \n\\multicolumn{3}{|c|}{TOTAL} & 18.80 \\\\ \\hline\n\\end{tabular}\n\\end{center}\n\\closing{Seal or signature:}\n\\end{letter}\n\\end{document}")\n
     "{:ok, :ok}"\n
     iex> LaTeXToPdf.stop()\n
  """
  @spec generate(any) :: {:ok, :ok}
  def generate(latex) do
    {:ok, GenServer.cast(__MODULE__, {:generate, latex})}
  end

  # GenServer callbacks

  @impl true
  def init(_init_arg) do
    Logger.info("[LaTeXToPdf] GenServer LaTeXToPdf initialized")
    {:ok, []}
  end

  @impl true
  def handle_cast({:generate, latex}, data) do
    filename = generate_filename()
    if !File.exists?("out/"), do: File.mkdir("out/")
    Iona.source(latex) |> Iona.write!(filename)
    Logger.info("[LaTeXToPdf] PDF Created. Output file: #{filename}")
    {:noreply, [{filename, latex} | data]}
  end

  # Private functions

  @spec generate_filename() :: String.t()
  defp generate_filename() do
    {{y, mon, d},{h, min, s}} = :calendar.local_time()
    "out/bill-#{y}-#{mon}-#{d}-#{h}-#{min}-#{s}.pdf"
  end

end
