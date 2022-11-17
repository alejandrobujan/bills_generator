defmodule Core.Leader do
  @moduledoc """
  Módulo que implementa o compoñente líder dunha arquitectura líder-traballador.

  É un proceso que permite rexistrar traballadores que use o behaviour `Core.StandardServer` e
  que permite recibir peticións a estos servizos, redirixíndoas a un traballador de dito servizo
  que esté disponible, realizando unha repartición da carga seguindo unha estratexia FIFO
  (First In First Out).

  Ademais, este proceso líder comproba cada certos segundos (`@workload_check_period`) a carga
  dos distintos servizos rexistrados, para modificar o número de traballadores de forma dinámica.
  En caso de que un servizo estea sobrecargado (carga maior
  ao umbral de trigger `@workload_trigger_max`), aumenta o número de traballadores de xeito que
  a carga que teña o servizo sexa como moito o umbral de carga máximo _ideal_ (`@workload_max`).
  En caso de que un servizo estea subutilizado (carga menor ao umbral de trigger
  `@workload_trigger_min`), reduce o número de traballadores de xeito que a carga que teña o
  servizo sexa como mínimo o umbral de carga mínimo _ideal_ (@workload_min).

  Así, intentamos ter a carga sempre entre [@workload_interval_min, @workload_interval_max]
  para cada servizo, pero modificamos o número de traballadores unha vez se pasen os umbrales
  "críticos" (@workload_trigger_min e @workload_trigger_max). Así conséguese unha boa reacción
  aos cambios da carga de peticións, para aproveitar os recursos o mellor posible.

  Este proceso líder implementa o behaviour `GenServer` para poder ser supervisado
  de forma sinxela.
  """

  alias Core.ServiceHandler
  use GenServer
  require Logger

  @workload_trigger_max 0.9
  @workload_trigger_min 0.2

  @workload_interval_max 0.8
  @workload_interval_min 0.3

  @workload_check_period 5_000

  # Public API

  @doc """
  Inicia un proceso líder. Permite rexistrar servizos mediante unha `Keyword List`, onde
  a clave é un átomo que identifica ao servizo, e o valor é unha tupla na que o primeiro elemento
  é o módulo do servizo, e o segundo é o número mínimo de traballadores que se queren poder ter.

  ## Exemplos:
      iex> Core.Leader.start_link([])
      iex> Process.whereis(Core.Leader) |> Process.alive?
      true
      iex> Core.Leader.stop()
  """
  @spec start_link(Keyword.t({StandardServer, pos_integer()})) :: {:ok, pid()}
  def start_link(services_spec) do
    GenServer.start_link(__MODULE__, services_spec, name: __MODULE__)
  end

  @doc """
  Para o proceso líder

  ## Exemplos:
      iex> Core.Leader.start_link([])
      iex> Core.Leader.stop()
      :ok
  """
  @spec stop() :: :ok
  def stop() do
    # Stopping the leader will also stop all linked workers
    GenServer.stop(__MODULE__)
  end

  @doc """
  Realiza unha petición `get` ao líder, se existe o servizo solicitado,
  agarda pola resposta e a devolve, senón, devolve a resposta de erro
  `{:error, :service_not_found}`.

  ## Exemplos:
      iex> Core.Leader.start_link([])
      iex> Core.Leader.get(:some_service)
      {:error, :service_not_found}
      iex> Core.Leader.stop()
  """
  @spec get(atom()) :: {:ok, Any} | {:error, Any}
  def get(service) do
    case GenServer.call(__MODULE__, {:get, service}) do
      :wait_for_response ->
        receive do
          {message, __MODULE__} -> {:ok, message}
        end

      other_response ->
        {:error, other_response}
    end
  end

  @doc """
    Realiza unha petición ao líder para obter todos os servizos que ten rexistrados.\
  """
  @spec get_services() :: list(atom())
  def get_services() do
    GenServer.call(__MODULE__, :get_services)
  end

  @doc """
  Función que utilizan os traballadores dun certo servizo para indicar que remataron
  o seu traballo, e que o líder debería de redirixir a resposta ao cliente que teña
  asignado dito traballador, ademáis de marcar ao traballador como libre.

  É unha petición asíncrona (cast), pois ao traballador non lle interesa ter a resposta do
  líder.
  """
  @spec redirect(atom(), pid(), any) :: :ok
  def redirect(service, worker, message) do
    GenServer.cast(__MODULE__, {:redirect, service, worker, message})
  end

  # GenServer callbacks

  @impl GenServer
  def init(services_spec) do
    Logger.debug("Leader initialized")

    services =
      Enum.map(services_spec, fn {service, {module, min_workers}} ->
        {
          service,
          ServiceHandler.new(service, module, min_workers)
        }
      end)
      |> Map.new()

    {:ok, _pid} = Task.start(fn -> check_services_worload(@workload_check_period) end)

    {:ok, services}
  end

  @impl GenServer
  def handle_call({:get, service}, client, services) when is_map_key(services, service) do
    service_handler = services[service]

    new_service_handler =
      if ServiceHandler.all_workers_busy?(service_handler) do
        ServiceHandler.enqueue_client(service_handler, client)
      else
        ServiceHandler.assign_job(service_handler, client)
      end

    {:reply, :wait_for_response, %{services | service => new_service_handler}}
  end

  def handle_call({:get, _service}, _from, services),
    do: {:reply, :service_not_found, services}

  def handle_call(:get_services, _from, services),
    do: {:reply, Map.keys(services), services}

  @impl GenServer
  def handle_cast({:redirect, service, worker, message}, services)
      when is_map_key(services, service) do
    service_handler = services[service]

    {client, new_service_handler} = ServiceHandler.free_worker(service_handler, worker)
    {client_pid, _client_tag} = client

    send(client_pid, {message, __MODULE__})

    new_service_handler =
      if ServiceHandler.any_pending_client?(new_service_handler) do
        # We know for sure that there is at least 1 free worker, since we have just
        # freed one
        ServiceHandler.assign_job(new_service_handler)
      else
        new_service_handler
      end

    {:noreply, %{services | service => new_service_handler}}
  end

  # If the service is not registered, we ignore the redirect request
  @impl GenServer
  def handle_cast({:redirect, _service, _worker, _message}, services),
    do: {:noreply, services}

  @impl GenServer
  def handle_info({:check, period}, services) do
    Logger.info("Starting workload checking")

    new_services =
      Enum.map(services, fn {service, service_handler} ->
        total_workers = ServiceHandler.total_workers(service_handler)
        total_free_workers = ServiceHandler.total_free_workers(service_handler)

        workload_rate = 1 - total_free_workers / total_workers

        new_service_handler = handle_workload_rate(service_handler, workload_rate)

        {service, new_service_handler}
      end)
      |> Map.new()

    {:ok, _pid} = Task.start(fn -> check_services_worload(period) end)

    {:noreply, new_services}
  end

  @spec check_services_worload(pos_integer()) :: :ok
  defp check_services_worload(period) do
    Process.sleep(period)
    send(__MODULE__, {:check, period})
    :ok
  end

  @spec handle_workload_rate(ServiceHandler.t(), float()) :: ServiceHandler.t()
  defp handle_workload_rate(service_handler, workload_rate)
       when workload_rate > @workload_trigger_max do
    service = service_handler.service
    total_workers = ServiceHandler.total_workers(service_handler)
    total_free_workers = ServiceHandler.total_free_workers(service_handler)

    Logger.info(
      "Excessive workload trigger for #{service}: there are #{total_workers} workers and #{total_free_workers} free workers. #{workload_rate * 100}% workload"
    )

    # If services are >90% workloaded, we will lower it to <80%.
    rate_diff = workload_rate - @workload_interval_max
    # We have to spawn rate_diff*total_workers workers
    workers_to_spawn = ceil(rate_diff * total_workers)

    Logger.info("Spawning #{workers_to_spawn} workers for #{service}")

    new_service_handler = ServiceHandler.spawn_workers(service_handler, workers_to_spawn)
    # We have to assign the new workers to the pending clients, but no more
    # than total_pending_clients or total_free_workers
    jobs_to_reasssign =
      min(
        ServiceHandler.total_pending_clients(new_service_handler),
        ServiceHandler.total_free_workers(new_service_handler)
      )

    new_service_handler = ServiceHandler.assign_jobs(new_service_handler, jobs_to_reasssign)

    new_service_handler
  end

  defp handle_workload_rate(service_handler, workload_rate)
       when workload_rate < @workload_trigger_min do
    service = service_handler.service
    total_workers = ServiceHandler.total_workers(service_handler)
    total_free_workers = ServiceHandler.total_free_workers(service_handler)
    min_workers = service_handler.min_workers

    Logger.info(
      "Low workload trigger for #{service}: there are #{total_workers} workers and #{total_free_workers} free workers. #{workload_rate * 100}% workload"
    )

    # If services are <20% workloaded, we will raise it to >30%.
    rate_diff = @workload_interval_min - workload_rate
    # We have to kill rate_diff*total_workers workers, but no more than available free_workers
    # It is akward that workers_to_kill > free workers, but it is better to ensure it.
    max_workers_to_kill = min(total_workers - min_workers, total_free_workers)
    workers_to_kill = min(ceil(rate_diff * total_workers), max_workers_to_kill)

    new_service_handler =
      cond do
        total_free_workers == 0 ->
          Logger.debug("Not killing any workers for #{service}, no free workers")
          service_handler

        total_workers == min_workers ->
          Logger.debug(
            "Not killing any workers for #{service}, min_workers reached (#{min_workers})"
          )

          service_handler

        true ->
          Logger.info("Killing #{workers_to_kill} workers for #{service}")
          ServiceHandler.kill_workers(service_handler, workers_to_kill)
      end

    new_service_handler
  end

  defp handle_workload_rate(service_handler, _workload_rate), do: service_handler
end
