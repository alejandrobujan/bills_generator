defmodule BillsGenerator.Test.Benchmark do
  alias BillsGenerator.Repository.{Repo, BillDao}
  alias BillsGenerator.Test.Utils
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
  defp generate_and_wait(n, sample_freq) do
    1..n |> Enum.each(fn _x -> BillsGenerator.Application.generate_bill(@valid_bill_request) end)
    Utils.wait_until_bills_completed(n, sample_freq)
    Repo.delete_all(BillDao)
    Utils.restart_application()
  end

  defp seconds_to_nano(seconds) do
    seconds * 1_000_000_000
  end

  @tag :benchmark
  @tag timeout: :infinity
  test "test throughput: benchmark generate 500 bills takes less than 60s" do
    # Ensure application has no previous workload and did not scale workers
    Utils.restart_application()

    output =
      Benchee.run(
        %{
          "Generate 500 bills" => fn -> generate_and_wait(500, 1000) end
        },
        print: [
          benchmarking: false,
          configuration: false,
          fast_warning: false
        ],
        # add Benchee.Formatters.Console to formatters if results need to be printed
        formatters: []
      )

    results = Enum.at(output.scenarios, 0)
    assert results.run_time_data.statistics.average <= seconds_to_nano(60)
  end

  test "test latency: benchmark generate 1 bill takes less than 500ms" do
    # Ensure application has no previous workload and did not scale workers
    Utils.restart_application()

    output =
      Benchee.run(
        %{
          "Generate 1 bill" => fn -> generate_and_wait(1, 10) end
        },
        print: [
          benchmarking: false,
          configuration: false,
          fast_warning: false
        ],
        # add Benchee.Formatters.Console to formatters if results need to be printed
        formatters: []
      )

    results = Enum.at(output.scenarios, 0)
    assert results.run_time_data.statistics.average <= seconds_to_nano(0.5)
  end
end
