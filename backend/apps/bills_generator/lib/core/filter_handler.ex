defmodule BillsGenerator.Core.FilterHandler do
  @moduledoc """
  Módulo que se encarga de xestionar os traballadores dun GenFilter.

  Garda a información sobre o módulo líder, o módulo traballador, a lista actual de traballadores,
  os traballadores que están libres, os traballadores que están ocupados e qué resposta están atendendo,
  a cola de peticións que están esperando a recibir unha resposta, e o número mínimo de traballadores que ten
  que ter dito líder .
  """

  alias BillsGenerator.Core.FilterHandler

  @enforce_keys [
    :leader_module,
    :worker_module,
    :workers,
    :free_workers,
    :busy_workers,
    :request_queue,
    :min_workers,
    :next_worker_id
  ]

  defstruct [
    :leader_module,
    :worker_module,
    :workers,
    :free_workers,
    :busy_workers,
    :request_queue,
    :min_workers,
    :next_worker_id
  ]

  @type t() :: %FilterHandler{
          leader_module: module(),
          worker_module: module(),
          workers: list(GenServer.server()),
          free_workers: :queue.queue(GenServer.server()),
          busy_workers: %{GenServer.server() => any()},
          request_queue: :queue.queue(any()),
          min_workers: pos_integer(),
          next_worker_id: pos_integer()
        }

  @doc """
  Crea unha nova instancia de `FilterHandler` a partir dun nome do servizo, o módulo que o implementa (que debe
  implementar o comportamento `StandardServer`), e o número mínimo de traballadores que ten que ter dito servizo.
  """
  @spec new(module(), module(), pos_integer()) :: t()
  def new(leader_module, worker_module, min_workers) do
    empty_handler = %FilterHandler{
      leader_module: leader_module,
      worker_module: worker_module,
      workers: [],
      free_workers: :queue.new(),
      busy_workers: %{},
      request_queue: :queue.new(),
      min_workers: min_workers,
      next_worker_id: 1
    }

    FilterHandler.spawn_workers(empty_handler, min_workers)
  end

  @doc """
  Restaura un handler previo, cuns traballadores novos.
  """
  def restore(
        %FilterHandler{
          leader_module: leader_module,
          worker_module: worker_module,
          request_queue: request_queue,
          busy_workers: busy_workers,
          min_workers: min_workers,
          next_worker_id: next_worker_id
        } = handler
      ) do
    num_workers = FilterHandler.total_workers(handler)

    # Return all requests that were processing by a stopped worker in busy_workes to requests queue
    uncompleted_requests =
      busy_workers
      |> Map.values()
      |> Enum.reduce(:queue.new(), fn request, queue ->
        :queue.in(request, queue)
      end)

    new_request_queue = :queue.join(uncompleted_requests, request_queue)

    # Do not save workers pids, since if the leader was killed,
    # its workers would've been killed too (linked processes).
    #  Then, it is not necessary to kill previous workers.
    new_handler = %FilterHandler{
      leader_module: leader_module,
      worker_module: worker_module,
      workers: [],
      free_workers: :queue.new(),
      busy_workers: %{},
      request_queue: new_request_queue,
      min_workers: min_workers,
      next_worker_id: next_worker_id
    }

    FilterHandler.spawn_and_assign_workers(new_handler, num_workers)
  end

  @doc """
  Crea un novo traballador para o servizo, engadíndoo á cola de traballadores libres. Devolve o `FilterHandler` actualizado.
  """
  @spec spawn_worker(t()) :: t()
  def spawn_worker(handler) do
    worker_id = handler.next_worker_id

    worker_name =
      (Atom.to_string(handler.leader_module) <> "_worker_#{worker_id}")
      |> String.to_atom()

    {:ok, new_worker} = handler.worker_module.start_link(handler.leader_module, worker_name)

    %FilterHandler{
      handler
      | workers: [new_worker | handler.workers],
        free_workers: :queue.in(new_worker, handler.free_workers),
        next_worker_id: worker_id + 1
    }
  end

  @doc """
  Crea `n` traballadores novos para o servizo, engadíndoos á cola de traballadores libres. Devolve o `FilterHandler` actualizado.
  """
  @spec spawn_workers(t(), non_neg_integer()) :: t()
  def spawn_workers(handler, 0), do: handler

  def spawn_workers(handler, n),
    do:
      spawn_worker(handler)
      |> spawn_workers(n - 1)

  @doc """
  Crea `n` traballadores novos para o servizo, e asígnaos ás posibles peticions pendientes de procesar
  """
  @spec spawn_and_assign_workers(t(), pos_integer) ::
          t()
  def spawn_and_assign_workers(handler, n) do
    new_handler = spawn_workers(handler, n)
    pending_requests = FilterHandler.total_pending_requests(new_handler)

    # We have to assign jobs, but no more than spawned workers or the number of the pending requests
    jobs_to_assign = min(pending_requests, n)
    FilterHandler.assign_jobs(new_handler, jobs_to_assign)
  end

  @doc """
  Elimina un traballador do servizo, mandándolle parar e eliminándoo da cola de traballadores libres
  e da lista de traballadores. Devolve o `FilterHandler` actualizado.

  Precondición: A cola de traballadores libres non debe estar baleira.
  """
  @spec kill_worker(t()) :: t()
  def kill_worker(handler) do
    {{:value, worker_to_kill}, other_workers} = :queue.out(handler.free_workers)
    :ok = handler.worker_module.stop(worker_to_kill)

    %FilterHandler{
      handler
      | workers: List.delete(handler.workers, worker_to_kill),
        free_workers: other_workers
    }
  end

  @doc """
  Elimina `n` traballadores do servizo, mandándolles parar e eliminándoos da cola de traballadores libres
  e da lista de traballadores. Devolve o `FilterHandler` actualizado.

  Precondición: A cola de traballadores libres ten que ter polo menos `n` traballadores.
  """
  @spec kill_workers(t(), non_neg_integer()) :: t()
  def kill_workers(handler, 0), do: handler
  def kill_workers(handler, n), do: handler |> kill_worker |> kill_workers(n - 1)

  @doc """
  Devolve `true` se todos os traballadores están ocupados, e `false` no caso contrario.
  """
  @spec all_workers_busy?(t()) :: boolean()
  def all_workers_busy?(handler), do: :queue.is_empty(handler.free_workers)

  @doc """
  Devolve `true` se hai algún cliente esperando a resposta na cola de clientes, e `false` no caso contrario.
  """
  @spec any_pending_request?(t()) :: boolean()
  def any_pending_request?(handler), do: not :queue.is_empty(handler.request_queue)

  @doc """
  Mete a un cliente na cola de clientes que esperan a resposta. Devolve o `FilterHandler` actualizado.
  """
  @spec enqueue_request(t(), any()) :: t()
  def enqueue_request(handler, request),
    # Request queue stores only input data to the filter
    do: %FilterHandler{
      handler
      | request_queue: :queue.in(request, handler.request_queue)
    }

  @doc """
  Saca da cola de clientes ao primeiro que está esperando. Devolve o cliente que se sacou e o `FilterHandler` actualizado.
  """
  @spec dequeue_request(t()) :: {any(), t()}
  def dequeue_request(handler) do
    {{:value, request}, new_queue} = :queue.out(handler.request_queue)
    {request, %FilterHandler{handler | request_queue: new_queue}}
  end

  @doc """
  Asigna un traballador libre a un cliente determinado, e devolve o novo estado do `FilterHandler`.

  Precondición: A cola de traballadores libres non debe estar baleira.
  """
  @spec assign_job(t(), any()) :: t()
  def assign_job(handler, request) do
    {{:value, worker}, other_workers} = :queue.out(handler.free_workers)
    busy_workers = Map.put(handler.busy_workers, worker, request)
    handler.worker_module.process_filter(worker, request)

    %FilterHandler{handler | free_workers: other_workers, busy_workers: busy_workers}
  end

  @doc """
  Asigna un traballador libre ao primeiro cliente que estea esperando na cola. Devolve o `FilterHandler` actualizado
  coa información da asignación do traballador ao cliente.
  """
  @spec assign_job(t()) :: t()
  def assign_job(handler) do
    # Assign a free worker to the first client on the queue
    {request, new_handler} = FilterHandler.dequeue_request(handler)
    FilterHandler.assign_job(new_handler, request)
  end

  @doc """
  Asigna `n` traballadores libres aos primeiros `n` clientes que estean esperando na cola. Devolve o `FilterHandler` actualizado.

  Precondición: Ten que haber como mínimo `n` traballadores libres, e `n` clientes esperando na cola.
  """
  @spec assign_jobs(t(), non_neg_integer()) :: t()
  def assign_jobs(handler, 0), do: handler

  def assign_jobs(handler, n) do
    handler |> assign_job() |> assign_jobs(n - 1)
  end

  @doc """
  Libera a un traballador que esté ocupado. Devolve o cliente que tiña asignado e o `FilterHandler`
  coa información actualizada.

  Precondición: O traballador que se pida liberar ten que estar ocupado.
  """
  @spec free_worker(t(), GenServer.server()) ::
          t()
  def free_worker(handler, worker) do
    {_input_data, new_busy_workers} = Map.pop!(handler.busy_workers, worker)
    new_free_workers = :queue.in(worker, handler.free_workers)

    %FilterHandler{handler | free_workers: new_free_workers, busy_workers: new_busy_workers}
  end

  @doc """
  Devolve o número de clientes que están esperando na cola.
  """
  @spec total_pending_requests(t()) :: non_neg_integer()
  def total_pending_requests(handler), do: :queue.len(handler.request_queue)

  @doc """
  Devolve o número de traballadores libres.
  """
  @spec total_free_workers(t()) :: non_neg_integer()
  def total_free_workers(handler), do: :queue.len(handler.free_workers)

  @doc """
  Devolve o número total de traballadores que ten o servizo.
  """
  @spec total_workers(t()) :: non_neg_integer()
  def total_workers(handler), do: length(handler.workers)

  @doc """
  Stop all workers
  """
  @spec stop_workers(t()) :: t()
  def stop_workers(handler) do
    handler.workers
    |> Enum.each(fn worker -> handler.worker_module.stop(worker) end)

    %FilterHandler{handler | workers: [], free_workers: :queue.new(), busy_workers: %{}}
  end
end
