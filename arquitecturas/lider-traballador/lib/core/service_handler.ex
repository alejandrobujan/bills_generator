defmodule Core.ServiceHandler do
  @moduledoc """
  Módulo que se encarga de representar o estado internos dos servizos rexistrados no líder.

  Garda a información sobre o nome do servizo, o módulo ao que pertence, a lista actual de traballadores,
  os traballadores que están libres, os traballadores que están ocupados e a que cliente están atendendo,
  a cola de clientes que están esperando a recibir unha resposta, e o número mínimo de traballadores que ten
  que ter dito servizo.
  """

  alias Core.ServiceHandler

  @enforce_keys [
    :service,
    :module,
    :workers,
    :free_workers,
    :busy_workers,
    :client_queue,
    :min_workers,
    :next_worker_id
  ]
  defstruct [
    :service,
    :module,
    :workers,
    :free_workers,
    :busy_workers,
    :client_queue,
    :min_workers,
    :next_worker_id
  ]

  @type t() :: %Core.ServiceHandler{
          service: atom(),
          module: StandardServer,
          workers: list(GenServer.server()),
          free_workers: :queue.queue(GenServer.server()),
          busy_workers: %{GenServer.server() => GenServer.from()},
          client_queue: :queue.queue(GenServer.from()),
          min_workers: pos_integer(),
          next_worker_id: pos_integer()
        }

  @doc """
  Crea unha nova instancia de `Core.ServiceHandler` a partir dun nome do servizo, o módulo que o implementa (que debe
  implementar o comportamento `StandardServer`), e o número mínimo de traballadores que ten que ter dito servizo.
  """
  @spec new(atom(), StandardServer, pos_integer()) :: ServiceHandler.t()
  def new(service, module, min_workers) do
    empty_handler = %Core.ServiceHandler{
      service: service,
      module: module,
      workers: [],
      free_workers: :queue.new(),
      busy_workers: %{},
      client_queue: :queue.new(),
      min_workers: min_workers,
      next_worker_id: 1
    }

    ServiceHandler.spawn_workers(empty_handler, min_workers)
  end

  @doc """
  Crea un novo traballador para o servizo, engadíndoo á cola de traballadores libres. Devolve o `ServiceHandler` actualizado.
  """
  @spec spawn_worker(ServiceHandler.t()) :: ServiceHandler.t()
  def spawn_worker(handler) do
    worker_id = handler.next_worker_id

    worker_name =
      (Atom.to_string(handler.service) <> "_worker_#{worker_id}")
      |> String.to_atom()

    {:ok, new_worker} = handler.module.start_link(handler.service, worker_name)

    %Core.ServiceHandler{
      handler
      | workers: [new_worker | handler.workers],
        free_workers: :queue.in(new_worker, handler.free_workers),
        next_worker_id: worker_id + 1
    }
  end

  @doc """
  Crea `n` traballadores novos para o servizo, engadíndoos á cola de traballadores libres. Devolve o `ServiceHandler` actualizado.
  """
  @spec spawn_workers(ServiceHandler.t(), pos_integer()) :: ServiceHandler.t()
  def spawn_workers(handler, n) do
    Enum.reduce(1..n, handler, fn _, acc -> spawn_worker(acc) end)
  end

  @doc """
  Elimina un traballador do servizo, mandándolle parar e eliminándoo da cola de traballadores libres
  e da lista de traballadores. Devolve o `ServiceHandler` actualizado.

  Precondición: A cola de traballadores libres non debe estar baleira.
  """
  @spec kill_worker(ServiceHandler.t()) :: ServiceHandler.t()
  def kill_worker(handler) do
    {{:value, worker_to_kill}, other_workers} = :queue.out(handler.free_workers)
    :ok = handler.module.stop(worker_to_kill)

    %Core.ServiceHandler{
      handler
      | workers: List.delete(handler.workers, worker_to_kill),
        free_workers: other_workers
    }
  end

  @doc """
  Elimina `n` traballadores do servizo, mandándolles parar e eliminándoos da cola de traballadores libres
  e da lista de traballadores. Devolve o `ServiceHandler` actualizado.

  Precondición: A cola de traballadores libres ten que ter polo menos `n` traballadores.
  """
  @spec kill_workers(ServiceHandler.t(), pos_integer()) :: ServiceHandler.t()
  def kill_workers(handler, n) do
    Enum.reduce(1..n, handler, fn _, acc -> kill_worker(acc) end)
  end

  @doc """
  Devolve `true` se todos os traballadores están ocupados, e `false` no caso contrario.
  """
  @spec all_workers_busy?(ServiceHandler.t()) :: boolean()
  def all_workers_busy?(handler), do: :queue.is_empty(handler.free_workers)

  @doc """
  Devolve `true` se hai algún cliente esperando a resposta na cola de clientes, e `false` no caso contrario.
  """
  @spec any_pending_client?(ServiceHandler.t()) :: boolean()
  def any_pending_client?(handler), do: not :queue.is_empty(handler.client_queue)

  @doc """
  Mete a un cliente na cola de clientes que esperan a resposta. Devolve o `ServiceHandler` actualizado.
  """
  @spec enqueue_client(ServiceHandler.t(), GenServer.from()) :: ServiceHandler.t()
  def enqueue_client(handler, client),
    do: %ServiceHandler{handler | client_queue: :queue.in(client, handler.client_queue)}

  @doc """
  Saca da cola de clientes ao primeiro que está esperando. Devolve o cliente que se sacou e o `ServiceHandler` actualizado.
  """
  @spec dequeue_client(ServiceHandler.t()) :: {GenServer.from(), ServiceHandler.t()}
  def dequeue_client(handler) do
    {{:value, client}, new_queue} = :queue.out(handler.client_queue)
    {client, %ServiceHandler{handler | client_queue: new_queue}}
  end

  @doc """
  Asigna un traballador libre a un cliente determinado, e devolve o novo estado do `ServiceHandler`.

  Precondición: A cola de traballadores libres non debe estar baleira.
  """
  @spec assign_job(ServiceHandler.t(), GenServer.from()) ::
          ServiceHandler.t()
  def assign_job(handler, client) do
    {{:value, worker}, other_workers} = :queue.out(handler.free_workers)
    busy_workers = Map.put(handler.busy_workers, worker, client)

    handler.module.get(worker)

    %ServiceHandler{handler | free_workers: other_workers, busy_workers: busy_workers}
  end

  @doc """
  Asigna un traballador libre ao primeiro cliente que estea esperando na cola. Devolve o `ServiceHandler` actualizado
  coa información da asignación do traballador ao cliente.
  """
  @spec assign_job(ServiceHandler.t()) ::
          ServiceHandler.t()
  def assign_job(handler) do
    # Assign a free worker to the first client on the queue
    {new_client, new_handler} = ServiceHandler.dequeue_client(handler)
    ServiceHandler.assign_job(new_handler, new_client)
  end

  @doc """
  Asigna `n` traballadores libres aos primeiros `n` clientes que estean esperando na cola. Devolve o `ServiceHandler` actualizado.

  Precondición: Ten que haber como mínimo `n` traballadores libres, e `n` clientes esperando na cola.
  """
  @spec assign_jobs(ServiceHandler.t(), non_neg_integer()) :: ServiceHandler.t()
  def assign_jobs(handler, 0), do: handler

  def assign_jobs(handler, n) do
    assign_jobs(assign_job(handler), n - 1)
  end

  @doc """
  Libera a un traballador que esté ocupado. Devolve o cliente que tiña asignado e o `ServiceHandler`
  coa información actualizada.

  Precondición: O traballador que se pida liberar ten que estar ocupado.
  """
  @spec free_worker(ServiceHandler.t(), GenServer.server()) ::
          {GenServer.from(), ServiceHandler.t()}
  def free_worker(handler, worker) do
    new_free_workers = :queue.in(worker, handler.free_workers)
    {client, new_busy_workers} = Map.pop!(handler.busy_workers, worker)

    {client,
     %ServiceHandler{handler | free_workers: new_free_workers, busy_workers: new_busy_workers}}
  end

  @doc """
  Devolve o número de clientes que están esperando na cola.
  """
  @spec total_pending_clients(ServiceHandler.t()) :: non_neg_integer()
  def total_pending_clients(handler), do: :queue.len(handler.client_queue)

  @doc """
  Devolve o número de traballadores libres.
  """
  @spec total_free_workers(ServiceHandler.t()) :: non_neg_integer()
  def total_free_workers(handler), do: :queue.len(handler.free_workers)

  @doc """
  Devolve o número total de traballadores que ten o servizo.
  """
  @spec total_workers(ServiceHandler.t()) :: non_neg_integer()
  def total_workers(handler), do: length(handler.workers)

  @doc """
  Stop all workers
  """
  @spec stop_workers(ServiceHandler.t()) :: ServiceHandler.t()
  def stop_workers(handler) do
    handler.workers
    |> Enum.each(fn worker -> handler.module.stop(worker) end)

    %ServiceHandler{handler | workers: [], free_workers: :queue.new(), busy_workers: %{}}
  end
end
