defmodule BillsGenerator.Core.GenFilterWorker do
  @moduledoc """

  Módulo que representa o comportamento que ten que cumplir un traballador de dun filtro.
  """
  alias BillsGenerator.Core.GenFilterWorker

  # Public API

  @doc "Inicia un traballador para este filtro"
  @callback start_link(atom(), atom()) :: {:ok, pid()}

  @doc "Petición `process_filter` ao filtro"
  @callback process_filter(GenServer.server(), any()) :: :ok

  @doc "Para o traballador indicado do filtro"
  @callback stop(GenServer.server()) :: :ok

  @doc "Función que é chamada cando o se chama `process_filter/1` para obter o resultado do filtro"
  @callback do_process_filter(any()) :: any()

  defmacro __using__(_) do
    quote do
      use GenServer
      require Logger

      @behaviour GenFilterWorker

      # Public API
      @impl GenFilterWorker
      def start_link(leader, name) do
        GenServer.start_link(__MODULE__, {leader, name}, name: name)
      end

      @impl GenFilterWorker
      def process_filter(server, input_data) do
        GenServer.cast(server, {:process_filter, input_data})
      end

      @impl GenFilterWorker
      def stop(server) do
        GenServer.stop(server, :normal)
      end

      # Implementing GenServer

      @impl GenServer
      def init({leader, name}) do
        {:ok, {leader, name}}
      end

      @impl GenServer
      def handle_cast({:process_filter, input_data}, {leader, name} = state) do
        message = __MODULE__.do_process_filter(input_data)
        leader.redirect(self(), message)
        {:noreply, state}
      end
    end
  end
end
