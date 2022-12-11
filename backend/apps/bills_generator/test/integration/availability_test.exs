defmodule BillsGenerator.Test.AvailabilityTest do
  alias BillsGenerator.Application
  alias BillsGenerator.Test.Utils
  alias BillsGenerator.Repository.{Repo, BillDao}
  use BillsGenerator.Test.DataCase

  @valid_bill_request """
  {
    "user": "A user",
    "bill": {
      "title": "A title",
      "purchaser": "A purchaser",
      "seller": "A seller",
      "products": [
        {
          "name": "A product",
          "price": 1.5,
          "quantity": 30
        },
        {
          "name": "Another product",
          "price": 15,
          "quantity": 2
        }
      ]
    },
    "config": {
      "font_size" : 10,
      "font_style" : "times",
      "paper_size" : "b5paper",
      "landscape" : true,
      "currency" : "euro"
    }
  }
  """

  @number_of_requests_workload 500
  @target_filter BillsGenerator.Filters.LatexToPdf

  test "filter restores previous number of workers when crashes" do
    # Generate some workload
    1..@number_of_requests_workload
    |> Enum.each(fn _ -> Application.generate_bill(@valid_bill_request) end)

    # sleep for 10s in order to ensure workload changes number of workers
    Process.sleep(10000)
    number_of_workers_before_crash = @target_filter.get_num_workers()

    @target_filter.stop()
    # Sleep to ensure filter is restarted by supervisor
    Process.sleep(500)
    number_of_workers_after_crash = @target_filter.get_num_workers()

    assert number_of_workers_before_crash == number_of_workers_after_crash

    # Do not wait for bills to finish, application will be restarted at the beggining of the next test
    # Utils.wait_until_bills_completed(number_of_bills, 500)
  end

  test "filter does not lose requests when crashes" do
    # Generate some workload
    1..@number_of_requests_workload
    |> Enum.each(fn _ -> Application.generate_bill(@valid_bill_request) end)

    # sleep for 3s so some bills are generated
    Process.sleep(3000)

    # Filter crashed. But state should be restored from stash.
    # We could simulate crash with `GenServer.stop(@target_filter,:kill)`, but it would show a log error in tests.
    # Killing the way below, is the same as `GenServer.stop(@target_filter,:normal)`
    @target_filter.stop()
    # Sleep to ensure filter is restarted by supervisor
    Process.sleep(500)

    Utils.wait_until_bills_completed(@number_of_requests_workload, 500)

    number_of_bills_completed = Repo.one(from(b in BillDao, select: count(b.pdf)))
    assert number_of_bills_completed == @number_of_requests_workload
  end

  test "filter does not lose request when a worker crashes" do
    target_worker_template = (@target_filter |> Atom.to_string()) <> "_worker_"

    # Generate some workload
    1..@number_of_requests_workload
    |> Enum.each(fn _ -> Application.generate_bill(@valid_bill_request) end)

    # sleep for 10s so some bills are generated
    Process.sleep(10000)

    num_workers = @target_filter.get_num_workers()

    # Kill all workers with a :normal reason, so error does not print in tests.
    1..num_workers
    |> Enum.each(fn i ->
      target_worker = (target_worker_template <> "#{i}") |> String.to_atom() |> Process.whereis()
      GenServer.stop(target_worker, :normal)
    end)

    # Now that all workers are dead, the filter should be restarting.

    # Sleep to ensure filter is restarted
    Process.sleep(500)

    Utils.wait_until_bills_completed(@number_of_requests_workload, 100)

    number_of_bills_completed = Repo.one(from(b in BillDao, select: count(b.pdf)))
    assert number_of_bills_completed == @number_of_requests_workload
  end
end
