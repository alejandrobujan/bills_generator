defmodule BillsGenerator.Tactics.FilterStash do
  @moduledoc """
  Módulo implementado para realizar a táctica de resposto. Garda o estado asociado a cada filtro,
  para que se poida recuperar o estado do filtro en calquera momento.
  """
  use GenServer
  require Logger

  # Public API
  def start_link(__init_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def stop(server) do
    GenServer.stop(server, :normal)
  end

  def put_handler(filter, handler) do
    GenServer.call(__MODULE__, {:put_handler, filter, handler})
  end

  def get_handler(filter) do
    GenServer.call(__MODULE__, {:get_handler, filter})
  end

  # Genserver implementation

  @impl GenServer
  def init(_args) do
    Logger.debug("#{__MODULE__} initialized")

    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:put_handler, filter, handler}, _from, filters_info) do
    {:reply, :ok, Map.put(filters_info, filter, handler)}
  end

  @impl GenServer
  def handle_call({:get_handler, filter}, _from, filters_info) do
    {:reply, Map.get(filters_info, filter), filters_info}
  end
end
