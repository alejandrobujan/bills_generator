defmodule BillCalculator do
  @moduledoc """
  Filtro encargado de calcular os prezos de cada liña de factura así como o total desta.
  Implementado con `GenServer` para poder supervisalo.
  """

  use GenServer
  require Logger

  @doc """
  Inicia o filtro calculadora.
  ## Exemplos:
    iex> BillCalculator.start_link([])\n
    iex> Process.whereis(BillCalculator) |> Process.alive?\n
    true\n
    iex> BillCalculator.stop()\n
  """
  @spec start_link(list) :: {:ok, pid()}
  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Para o filtro calculadora.
  ## Exemplos:
     iex> BillCalculator.start_link([])\n
     iex> BillCalculator.stop()\n
     iex> Process.whereis(BillCalculator)\n
     nil\n
  """
  @spec stop() :: :ok
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @doc """
  Recibe unha lista de liñas de pedido (a maiores de comprador e vendedor) e calcula os totais de cada liña e vai acumulando un total global. Envía a saída á entrada do seguinte filtro.
  ## Exemplos:
     iex> BillCalculator.start_link([])\n
     iex> BillCalculator.calc([%Product{name: Baguette, price: 0.75}], "Alejandro", "Sandra")\n
     "{:ok, :ok}"\n
     iex> BillCalculator.stop()\n
  """
  @spec calc(list(), String.t(), String.t()) :: {:ok, :ok}
  def calc(bill_lines, seller, purchaser) do
    {:ok, GenServer.cast(__MODULE__, {:calc, bill_lines, seller, purchaser})}
  end

  # GenServer callbacks

  @impl true
  def init(_init_arg) do
    Logger.info("[BillCalculator] GenServer BillCalculator initialized")
    {:ok, []}
  end

  @impl true
  def handle_cast({:calc, bill_lines, seller, purchaser}, data) do
    Logger.info("[BillCalculator] Piped to LaTeXFormatter filter")
    bill = calculate_bill(bill_lines)
    LaTeXFormatter.format(bill, seller, purchaser)
    {:noreply, [[bill: bill, seller: seller, purchaser: purchaser] | data]}
  end

  # Private functions

  defp calculate_bill([]), do: []

  defp calculate_bill(bill_lines), do: do_calculate_bill([], bill_lines, 0)

  defp do_calculate_bill(acc, [], total), do: {acc, total}

  defp do_calculate_bill(acc, [pair = {product, qty} | t], total) do
    do_calculate_bill([{pair, product.price * qty} | acc], t, total + product.price * qty)
  end

end
