defmodule IntegrationTest do
  alias Core.Leader
  alias Core.ServiceHandler
  alias Services.Service1
  alias Services.Service2

  use ExUnit.Case
  require Logger
  @task_multiplier 20

  # Service_1 has 1s of delay
  @service_1_delay 1000

  @service_1_min_workers 5
  @service_2_min_workers 1

  @service_1_spec {Service1, @service_1_min_workers}
  @service_2_spec {Service2, @service_2_min_workers}

  setup do
    {:ok, _pid} = Leader.start_link(service_1: @service_1_spec, service_2: @service_2_spec)

    on_exit(fn ->
      try do
        Leader.stop()
      catch
        :exit, {:noproc, _} -> :ok
      end
    end)
  end

  test "validates the integration of Leader and Service1" do
    assert Leader.get(:service_1) == {:ok, "Im Service1"}
  end

  test "validates the balancing of Leader with multiple simultaneous requests when there are multiple workers available" do
    # Sends @service_min_min_workers simultaneous request to leader. Each request should take ~1s
    tasks =
      Enum.map(1..@service_1_min_workers, fn _ ->
        Task.async(fn -> Leader.get(:service_1) end)
      end)

    Process.sleep(@service_1_delay + 500)

    # After 1.5 seconds all of the requests should be answered. If secuentially, it would
    # take @service_1_min_workers seconds

    Enum.each(tasks, fn task -> assert {:ok, _} = Task.yield(task, 1) end)
  end

  # This test is very sensible to current cpu work. If fails, @task_multiplier should
  # be increased to let the leader work propertly. Ideally, a large number of task_multiplier
  # should be used (like 100, for example), but the test time would increase. Leaving as it is
  # for now. It should take ~15 to run now.
  test "validates the leader spawns more workers if service is overloaded" do
    num_tasks = @task_multiplier * @service_1_min_workers
    now = Time.utc_now()

    tasks = Enum.map(1..num_tasks, fn _ -> Task.async(fn -> Leader.get(:service_1) end) end)

    Enum.each(tasks, fn task -> Task.await(task) end)

    elapsed = Time.diff(Time.utc_now(), now, :millisecond)

    # Logger.info("Elapsed time: #{elapsed}ms")
    # Logger.info("Expected time: #{@service_1_delay * @task_multiplier}ms")

    # It should take less time than if the leader didn't spawn more workers.
    assert elapsed < @task_multiplier * @service_1_delay
  end

  test "validates the leader expose the services propertly" do
    services = Leader.get_services()
    assert Enum.member?(services, :service_1)
    assert Enum.member?(services, :service_2)
  end

  test "validates the leader creates the service handler property" do
    name = :some_new_service
    module = Service1
    min_workers = 2
    handler = ServiceHandler.new(name, module, min_workers)

    # assert handler fields correctly
    assert handler.service == name
    assert handler.module == module
    assert handler.min_workers == min_workers
    assert :queue.is_empty(handler.client_queue)
    assert Map.keys(handler.busy_workers) == []

    assert ServiceHandler.total_workers(handler) == min_workers
    assert ServiceHandler.total_free_workers(handler) == min_workers
    assert ServiceHandler.all_workers_busy?(handler) == false
    assert ServiceHandler.any_pending_client?(handler) == false

    # clean up service handler workers
    ServiceHandler.kill_workers(handler, min_workers)
  end

  test "validates ServiceHandler spawns and kills workers propertly" do
    name = :some_new_service
    module = Service1
    min_workers = 2
    handler = ServiceHandler.new(name, module, min_workers)

    handler = ServiceHandler.spawn_worker(handler)
    assert ServiceHandler.total_workers(handler) == min_workers + 1
    assert ServiceHandler.total_free_workers(handler) == min_workers + 1
    assert ServiceHandler.all_workers_busy?(handler) == false

    handler = ServiceHandler.kill_worker(handler)
    assert ServiceHandler.total_workers(handler) == min_workers
    assert ServiceHandler.total_free_workers(handler) == min_workers

    # clean up service handler workers
    ServiceHandler.kill_workers(handler, min_workers)
  end

  test "validates ServiceHandler assigns jobs and frees workers propertly" do
    name = :some_new_service
    module = Service1
    min_workers = 2
    handler = ServiceHandler.new(name, module, min_workers)

    # assign one job to current process
    handler = ServiceHandler.assign_job(handler, self())
    assert ServiceHandler.total_free_workers(handler) == min_workers - 1
    assert ServiceHandler.all_workers_busy?(handler) == false
    assert handler.busy_workers |> Map.keys() |> length() == 1

    # Assign another job to current process
    handler = ServiceHandler.assign_job(handler, self())
    assert ServiceHandler.total_free_workers(handler) == min_workers - 2
    assert ServiceHandler.all_workers_busy?(handler) == true
    assert handler.busy_workers |> Map.keys() |> length() == 2

    [one_worker, another_worker] = handler.busy_workers |> Map.keys()

    # Free one worker
    {_client, handler} = ServiceHandler.free_worker(handler, one_worker)
    assert ServiceHandler.total_free_workers(handler) == min_workers - 1
    assert ServiceHandler.all_workers_busy?(handler) == false
    assert handler.busy_workers |> Map.keys() |> length() == 1

    # Free another worker
    {_client, handler} = ServiceHandler.free_worker(handler, another_worker)
    assert ServiceHandler.total_free_workers(handler) == min_workers
    assert ServiceHandler.all_workers_busy?(handler) == false
    assert handler.busy_workers |> Map.keys() |> length() == 0

    # clean up service handler workers
    ServiceHandler.kill_workers(handler, min_workers)
  end
end
