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
  @spec calc(BillRequest.t()) :: {:ok, :ok}
  def calc(bill_request) do
    {:ok, GenServer.cast(__MODULE__, {:calc, bill_request})}
  end

  # GenServer callbacks

  @impl true
  def init(_init_arg) do
    Logger.info("[BillCalculator] GenServer BillCalculator initialized")
    {:ok, []}
  end

  @impl true
  def handle_cast({:calc, bill_request}, data) do
    Logger.info("[BillCalculator] Piped to LaTeXFormatter filter")
    LaTeXFormatter.format(update_bill(bill_request))
    {:noreply, [bill_request | data]}
  end

  # Private functions

  defp update_bill(bill_request) do
    {list, total} = calculate_bill(bill_request.bill.lines)
    updated_bill = bill_request.bill
    updated_bill = %{updated_bill | lines: list}
    updated_bill = %{updated_bill | total: total}
    bill_request= %{bill_request | bill: updated_bill}
    bill_request
  end

  defp calculate_bill([]), do: {[], 0}

  defp calculate_bill(bill_lines), do: do_calculate_bill([], bill_lines, 0)

  defp do_calculate_bill(acc, [], total), do: {acc, total}

  defp do_calculate_bill(acc, [line = %BillLine{product: prod, quantity: qty} | t], total) do
    do_calculate_bill([ %{line | price: prod.price*qty} | acc], t, total + prod.price*qty)
  end

end
