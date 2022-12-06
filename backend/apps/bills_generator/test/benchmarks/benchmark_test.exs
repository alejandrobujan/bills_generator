defmodule BencheeUnitTest do
  alias BillsGenerator.Repository.{Repo, BillDao}
  import Ecto.Query, only: [from: 2]
  use BillsGenerator.DataCase

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
      "landscape" : true
    }
  }
  """
  defp generate_and_wait(n, sample_freq) do
    1..n |> Enum.each(fn _x -> BillsGenerator.Application.generate_bill(@valid_bill_request) end)
    wait_until(n, sample_freq)
  end

  # Query repo every `sample_freq ms`. The resulting time is at much, `sample_freq ms` more than the actual time.
  # This query increases overhead, but it is the only way to check if all the bills have
  # been generated. We could increase sleep time in order to reduce overhead.
  defp wait_until(n, sample_freq) do
    len = Repo.one(from(b in BillDao, select: count(b.pdf)))

    if len < n do
      Process.sleep(sample_freq)
      wait_until(n, sample_freq)
    else
      Repo.delete_all(BillDao)
      reset_application()
    end
  end

  defp reset_application() do
    Application.stop(:bills_generator)
    Application.start(:bills_generator)
  end

  defp seconds_to_nano(seconds) do
    seconds * 1_000_000_000
  end

  defp nano_to_seconds(nano) do
    nano / 1_000_000_000
  end

  @tag :benchmark
  @tag timeout: :infinity
  test "test throughput: benchmark generate 500 bills takes less than 60s" do
    IO.puts("\nTesting benchmarks, this may take a while...\n")
    # Ensure application has no previous workload and did not scale workers
    reset_application()

    output =
      Benchee.run(%{
        "Generate 500 bills" => fn -> generate_and_wait(500, 1000) end
      })

    results = Enum.at(output.scenarios, 0)
    assert results.run_time_data.statistics.average <= seconds_to_nano(60)
  end

  test "test latency: benchmark generate 1 bill takes less than 300ms" do
    # Ensure application has no previous workload and did not scale workers
    reset_application()

    output =
      Benchee.run(%{
        "Generate 1 bill" => fn -> generate_and_wait(1, 10) end
      })

    results = Enum.at(output.scenarios, 0)
    assert results.run_time_data.statistics.average <= seconds_to_nano(0.3)
  end
end
