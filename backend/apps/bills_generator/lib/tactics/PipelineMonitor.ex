defmodule BillsGenerator.Tactics.PipelineMonitor do
  alias BillsGenerator.Filters.{
    BillParser,
    BillCalculator,
    BillValidator,
    LatexFormatter,
    LatexToPdf,
    StoreInDatabase
  }

  use GenServer
  require Logger

  @filters [
    BillParser,
    BillCalculator,
    BillValidator,
    LatexFormatter,
    LatexToPdf,
    StoreInDatabase
  ]

  # Public API
  def start_link(__init_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def stop(server) do
    GenServer.stop(server, :normal)
  end

  def get_filter_info(filter) do
    GenServer.call(__MODULE__, {:get_filter_info, filter})
  end

  # Genserver implementation

  @impl GenServer
  def init(_args) do
    Logger.debug("#{__MODULE__} initialized")
    filters_info = @filters |> Enum.map(fn filter -> {filter, nil} end) |> Map.new()
    {:ok, _pid} = Task.start(fn -> check_filters(3000) end)
    {:ok, filters_info}
  end

  @impl GenServer
  def handle_call({:get_filter_info, filter}, _from, filters_info) do
    {:reply, Map.get(filters_info, filter), filters_info}
  end

  # TODO: When reset on filters, ask this module in order to get number of workers again.
  @impl GenServer
  def handle_info({:sample_filters_workers, period}, filters_info) do
    new_filters_info =
      filters_info
      |> Enum.map(fn {filter, previous_num_workers} ->
        # Update the number of workers for each filter only if filter is alive
        if filter.alive?() do
          {filter, filter.get_num_workers()}
        else
          {filter, previous_num_workers}
        end
      end)
      |> Map.new()

    print_filters_info(filters_info)

    {:ok, _pid} = Task.start(fn -> check_filters(period) end)
    {:noreply, new_filters_info}
  end

  defp check_filters(period) do
    Process.sleep(period)
    send(__MODULE__, {:sample_filters_workers, period})
    :ok
  end

  # format the filter_info map as a table string, where each column is a filter, the first row is the filter name
  # and the second row is the number of workers
  defp print_filters_info(filters_info) do
    # get leaf name from filter module name, e.g. "BillsGenerator.Filters.BillParser" -> "BillParser"
    filters_info_leaf_names =
      filters_info
      |> Enum.map(fn {filter, num_workers} ->
        {filter |> Atom.to_string() |> String.split(".") |> List.last(), num_workers}
      end)
      |> Map.new()

    filters_info_table = Scribe.format(filters_info_leaf_names, colorize: true)

    # TODO: Print this info in IO.puts? This would show the info when running tests,useful for debugging benchmarks...
    Logger.info("Filters number of workers info:\n#{filters_info_table}")
  end
end
