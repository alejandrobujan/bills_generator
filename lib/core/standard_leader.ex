defmodule Core.StandardLeader do
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
  alias Core.StandardLeader

  # Public API

  @doc """
    Inicia un proceso líder dos filtros.
  """
  @callback start_link() :: {:ok, pid()}

  @doc """
  Para o proceso líder
  """
  @callback stop() :: :ok

  @doc """
  Realiza unha petición `process_filter` ao líder cos datos de entrada
  ao filtro. O proceso líder é o encargado do que se fará ca salida do filtro.
  """
  @callback process_filter(any()) :: :ok

  @doc """
  Función que utilizan os traballadores dun certo servizo para indicar que remataron
  o seu traballo, e que o líder debería de redirixir a resposta ao cliente que teña
  asignado dito traballador, ademáis de marcar ao traballador como libre.

  É unha petición asíncrona (cast), pois ao traballador non lle interesa ter a resposta do
  líder.
  """
  @callback redirect(pid(), any()) :: :ok

  @callback get_worker_module() :: module()

  @callback next_action(any()) :: any()

  defmacro __using__(_) do
    quote do
      @workload_trigger_max 0.9
      @workload_trigger_min 0.2

      @workload_interval_max 0.8
      @workload_interval_min 0.3

      @workload_check_period 5_000

      use GenServer
      require Logger

      @behaviour StandardLeader

      @impl StandardLeader
      def start_link(__init_args) do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      @impl StandardLeader
      def stop() do
        # Stopping the leader will also stop all linked workers
        GenServer.stop(__MODULE__)
      end

      @impl StandardLeader
      def process_filter(input_data) do
        GenServer.cast(__MODULE__, {:process_filter, input_data, self()})
      end

      @impl StandardLeader
      def redirect(worker, output_data) do
        GenServer.cast(__MODULE__, {:redirect, worker, output_data})
      end

      # GenServer callbacks

      @impl GenServer
      def init(__init_args) do
        Logger.debug("#{__MODULE__} initialized")

        service_handler = ServiceHandler.new(__MODULE__, get_worker_module(), 1)

        {:ok, _pid} = Task.start(fn -> check_services_worload(@workload_check_period) end)

        {:ok, service_handler}
      end

      @impl GenServer
      def handle_cast({:process_filter, input_data, client}, service_handler) do
        new_service_handler =
          if ServiceHandler.all_workers_busy?(service_handler) do
            ServiceHandler.enqueue_request(service_handler, {client, input_data})
          else
            ServiceHandler.assign_job(service_handler, {client, input_data})
          end

        {:noreply, new_service_handler}
      end

      @impl GenServer
      def handle_cast({:redirect, worker, output_data}, service_handler) do
        {client, new_service_handler} = ServiceHandler.free_worker(service_handler, worker)

        next_action(output_data)

        new_service_handler =
          if ServiceHandler.any_pending_request?(new_service_handler) do
            # We know for sure that there is at least 1 free worker, since we have just
            # freed one
            ServiceHandler.assign_job(new_service_handler)
          else
            new_service_handler
          end

        {:noreply, new_service_handler}
      end

      @impl GenServer
      def handle_info({:check, period}, service_handler) do
        # Logger.info("Starting workload checking")

        total_workers = ServiceHandler.total_workers(service_handler)
        total_free_workers = ServiceHandler.total_free_workers(service_handler)

        workload_rate = 1 - total_free_workers / total_workers

        new_service_handler = handle_workload_rate(service_handler, workload_rate)

        {:ok, _pid} = Task.start(fn -> check_services_worload(period) end)

        {:noreply, new_service_handler}
      end

      defp check_services_worload(period) do
        Process.sleep(period)
        send(__MODULE__, {:check, period})
        :ok
      end

      defp handle_workload_rate(service_handler, workload_rate)
           when workload_rate > @workload_trigger_max do
        worker_module = service_handler.worker_module
        total_workers = ServiceHandler.total_workers(service_handler)
        total_free_workers = ServiceHandler.total_free_workers(service_handler)

        # Logger.info(
        #   "Excessive workload trigger for #{worker_module}: there are #{total_workers} workers and #{total_free_workers} free workers. #{workload_rate * 100}% workload"
        # )

        # If services are >90% workloaded, we will lower it to <80%.
        rate_diff = workload_rate - @workload_interval_max
        # We have to spawn rate_diff*total_workers workers
        workers_to_spawn = ceil(rate_diff * total_workers)

        # Logger.info("Spawning #{workers_to_spawn} workers for #{worker_module}")

        new_service_handler = ServiceHandler.spawn_workers(service_handler, workers_to_spawn)
        # We have to assign the new workers to the pending clients, but no more
        # than total_pending_clients or total_free_workers
        jobs_to_reasssign =
          min(
            ServiceHandler.total_pending_requests(new_service_handler),
            ServiceHandler.total_free_workers(new_service_handler)
          )

        new_service_handler = ServiceHandler.assign_jobs(new_service_handler, jobs_to_reasssign)

        new_service_handler
      end

      defp handle_workload_rate(service_handler, workload_rate)
           when workload_rate < @workload_trigger_min do
        worker_module = service_handler.worker_module
        total_workers = ServiceHandler.total_workers(service_handler)
        total_free_workers = ServiceHandler.total_free_workers(service_handler)
        min_workers = service_handler.min_workers

        # Logger.info(
        #   "Low workload trigger for #{worker_module}: there are #{total_workers} workers and #{total_free_workers} free workers. #{workload_rate * 100}% workload"
        # )

        # If services are <20% workloaded, we will raise it to >30%.
        rate_diff = @workload_interval_min - workload_rate

        # We have to kill rate_diff*total_workers workers, but no more than available free_workers
        # It is akward that workers_to_kill > free workers, but it is better to ensure it.
        max_workers_to_kill = min(total_workers - min_workers, total_free_workers)
        workers_to_kill = min(ceil(rate_diff * total_workers), max_workers_to_kill)

        new_service_handler =
          cond do
            total_free_workers == 0 ->
              # Logger.debug("Not killing any workers for #{worker_module}, no free workers")
              service_handler

            total_workers == min_workers ->
              # Logger.debug(
              #   "Not killing any workers for #{worker_module}, min_workers reached (#{min_workers})"
              # )

              service_handler

            true ->
              # Logger.info("Killing #{workers_to_kill} workers for #{worker_module}")
              ServiceHandler.kill_workers(service_handler, workers_to_kill)
          end

        new_service_handler
      end

      defp handle_workload_rate(service_handler, _workload_rate), do: service_handler
    end
  end
end
