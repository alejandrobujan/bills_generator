defmodule Core.StandardServer do
  @moduledoc """
  Módulo que representa o comportamento dun servizo estándar que pode ser rexistrado
  no líder. É necesario que os servizos que se queiran rexistrar utilicen este comportamento,
  xa que o líder espera unha interfaz estándar para poder comunicarse con eles.

  Para definir o comportamento do `get` dun servizo, o servizo ten que definir a función
  `handle_get/0`, xa que non se proporciona unha implementación por defecto para esta.
  """
  alias Core.StandardServer
  alias Core.Leader

  # Public API

  @doc "Inicia un traballador para este servizo"
  @callback start_link(atom(), atom()) :: {:ok, pid()}

  @doc "Petición `get` ao servizo"
  @callback get(GenServer.server()) :: :ok

  @doc "Para o traballador indicado do servizo"
  @callback stop(GenServer.server()) :: :ok

  @doc "Función que é chamada dentro de `get/1` para obter a resposta do servizo"
  @callback handle_get() :: any()

  defmacro __using__(_) do
    quote do
      use GenServer
      require Logger

      @behaviour StandardServer

      # Public API
      @impl StandardServer
      def start_link(service, name) do
        GenServer.start_link(__MODULE__, {service, name}, name: name)
      end

      @impl StandardServer
      def get(server) do
        GenServer.cast(server, :get)
      end

      @impl StandardServer
      def stop(server) do
        GenServer.stop(server, :normal)
      end

      # Implementing GenServer

      @impl GenServer
      def init({service, name}) do
        {:ok, {service, name}}
      end

      @impl GenServer
      def handle_cast(:get, {service, name} = state) do
        message = __MODULE__.handle_get()
        Logger.debug("Sending message from #{name} to leader: #{message}")
        Leader.redirect(service, self(), message)
        {:noreply, state}
      end
    end
  end
end
