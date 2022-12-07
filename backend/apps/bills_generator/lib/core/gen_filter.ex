defmodule BillsGenerator.Core.GenFilter do
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

  alias BillsGenerator.Core.ServiceHandler
  alias BillsGenerator.Core.GenFilter

  # Public API

  @doc """
    Inicia un proceso líder dos filtros.
  """
  @callback start_link(any()) :: {:ok, pid()}

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

  @callback worker_action(any()) :: any()

  @callback get_num_workers() :: non_neg_integer()

  @callback alive?() :: boolean()

  # Callback to execute code if needed on worker
  @callback on_error(caused_by :: module(), error_msg :: any(), input_data :: any()) :: :ok

  @callback next_action(any()) :: any()

  defmacro __using__(_) do
    quote do
      alias __MODULE__, as: LeaderModule
      alias BillsGenerator.Tactics.FilterStash

      defmodule Worker do
        alias BillsGenerator.Core.GenFilterWorker
        use GenFilterWorker

        @impl GenFilterWorker
        def do_process_filter({:error, module, error_msg, input_data} = error) do
          # When an error is produced in a step of the pipeline,
          # the error is propagated forward to the next steps,
          # until the last step, where the error is handled.
          # Error could be handled in middle steps if needed,
          # but final error output must be done by the last step
          # of the pipeline

          # Callback if error needs to be handled by worker
          LeaderModule.on_error(module, error_msg, input_data)

          # Always return the error as filter's output, so the leader will know
          # if an error happened
          error
        end

        @impl GenFilterWorker
        def do_process_filter(input_data) do
          # If an exception occurs when processing the input data in the filter worker,
          # the output of the filter will be {:error,error_msg}
          try do
            LeaderModule.worker_action(input_data)
          rescue
            exception ->
              # Return leader module instead of worker module, to hide worker implementation.
              {:error, LeaderModule, Exception.message(exception), input_data}
          end
        end
      end

      @workload_trigger_max 0.9
      @workload_trigger_min 0.2

      @workload_interval_max 0.8
      @workload_interval_min 0.3

      @workload_check_period 5_000

      use GenServer
      require Logger

      @behaviour GenFilter

      @impl GenFilter
      def start_link(__init_args) do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      @impl GenFilter
      def stop() do
        # Stopping the leader will also stop all linked workers
        GenServer.stop(__MODULE__)
      end

      @impl GenFilter
      def process_filter(input_data) do
        GenServer.cast(__MODULE__, {:process_filter, input_data})
      end

      @impl GenFilter
      def redirect(worker, output_data) do
        GenServer.cast(__MODULE__, {:redirect, worker, output_data})
      end

      @impl GenFilter
      def get_num_workers() do
        GenServer.call(__MODULE__, :get_num_workers)
      end

      @impl GenFilter
      def alive?() do
        pid = Process.whereis(__MODULE__)

        if pid == nil do
          false
        else
          Process.alive?(pid)
        end
      end

      # By default, do not handle error
      @impl GenFilter
      def on_error(caused_by, error_msg, input_data) do
        :ok
      end

      # GenServer callbacks

      @impl GenServer
      def init(__init_args) do
        Logger.debug("#{__MODULE__} initialized")

        # Trap exit of workers, so we can store the state when a worker dies, and restart the filter
        Process.flag(:trap_exit, true)

        # Restore tactic for availability improvement
        stored_handler = FilterStash.get_handler(__MODULE__)

        service_handler =
          if stored_handler != nil do
            Logger.debug("Restoring handler from FilterStash in module #{__MODULE__}")
            ServiceHandler.restore(stored_handler)
          else
            # We can call to worker module, since it is relative from current module, and
            # defined at first lines of this using
            Logger.debug("Creating new handler in #{__MODULE__}")
            ServiceHandler.new(__MODULE__, Worker, 1)
          end

        {:ok, _pid} = Task.start(fn -> check_services_worload(@workload_check_period) end)

        {:ok, service_handler}
      end

      @impl GenServer
      def handle_cast({:process_filter, input_data}, service_handler) do
        new_service_handler =
          if ServiceHandler.all_workers_busy?(service_handler) do
            ServiceHandler.enqueue_request(service_handler, input_data)
          else
            ServiceHandler.assign_job(service_handler, input_data)
          end

        {:noreply, new_service_handler}
      end

      @impl GenServer
      def handle_cast(
            {:redirect, worker, output_data},
            service_handler = %ServiceHandler{busy_workers: busy_workers}
          )
          when is_map_key(busy_workers, worker) do
        new_service_handler = ServiceHandler.free_worker(service_handler, worker)

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
      def handle_cast({:redirect, worker, output_data}, service_handler) do
        # When a worker who is not registered on service handler calls to redirect, we ignore it
        # This is specially useful when filter is restarted, so the handler is restored, but
        # calls from older workers who had just been killed should be ignored, since the request
        # they were processing will be handled by some of the new workers
        {:noreply, service_handler}
      end

      @impl GenServer
      def handle_call(:get_num_workers, _from, service_handler) do
        {:reply, ServiceHandler.total_workers(service_handler), service_handler}
      end

      @impl GenServer
      def handle_info({:check, period}, service_handler) do
        # Logger.info("Starting workload checking")
        total_workers = ServiceHandler.total_workers(service_handler)
        total_free_workers = ServiceHandler.total_free_workers(service_handler)

        # Logger.info("#{__MODULE__} has #{total_workers} workers")

        workload_rate = 1 - total_free_workers / total_workers

        new_service_handler = handle_workload_rate(service_handler, workload_rate)

        {:ok, _pid} = Task.start(fn -> check_services_worload(period) end)

        {:noreply, new_service_handler}
      end

      # When a worker dies, store handler to FilterStash and terminate filter
      # This is neccessary, since if a son process dies, the terminate/2 function
      # of GenServer will not be called.
      @impl GenServer
      def handle_info({:EXIT, _dead_worker, reason}, service_handler) do
        Logger.debug("#{__MODULE__} received a worker death. Restarting it.")
        FilterStash.put_handler(__MODULE__, service_handler)
        {:stop, reason, service_handler}
      end

      # When crashed or stopped, store handler to FilterStash, so when the filter
      # is restarted, it can restore the last state. This function is not called
      # when a son process dies, only when the current process crashes or is stopped.
      @impl GenServer
      def terminate(_reason, service_handler) do
        Logger.debug("#{__MODULE__} terminated")

        # Save handler to FilterStash
        FilterStash.put_handler(__MODULE__, service_handler)
        Logger.debug("Handler from #{__MODULE__} saved to FilterStash")
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

        # If services are >@workload_trigger_max% workloaded, we will lower it to <=@workload_interval_max%.
        rate_diff = workload_rate - @workload_interval_max
        workers_to_spawn = ceil(rate_diff * total_workers)

        # Logger.info("Spawning #{workers_to_spawn} workers for #{worker_module}")

        # We have to assign the new workers to the pending clients, but no more
        # than total_pending_clients or workers_to_spawn
        new_service_handler =
          ServiceHandler.spawn_and_assign_workers(
            service_handler,
            workers_to_spawn
          )

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

        # If services are <@workload_trigger_min% workloaded, we will raise it to >=@workload_interval_min%.
        rate_diff = @workload_interval_min - workload_rate

        # We have to kill rate_diff*total_workers workers, but no more than available free_workers
        # It is akward that workers_to_kill > free workers, but it is better to ensure it.
        max_workers_to_kill = min(total_workers - min_workers, total_free_workers)
        workers_to_kill = min(ceil(rate_diff * total_workers), max_workers_to_kill)

        new_service_handler = ServiceHandler.kill_workers(service_handler, workers_to_kill)

        new_service_handler
      end

      defp handle_workload_rate(service_handler, _workload_rate), do: service_handler

      defoverridable(on_error: 3)
    end
  end
end
