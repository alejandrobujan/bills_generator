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
  defp generate_and_wait(n) do
    1..n |> Enum.each(fn _x -> BillsGenerator.Application.generate_bill(@valid_bill_request) end)
    wait_until(n)
  end

  # Query repo every 500ms. The resulting time is at much, 500ms more than the actual time.
  defp wait_until(n) do
    len =
      Repo.all(from b in BillDao, where: not is_nil(b.pdf))
      |> Enum.count()

    IO.puts(len)

    if len < n do
      Process.sleep(500)
      wait_until(n)
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
  test "benchmark generate 500 bills takes less than 30s" do
    IO.puts("Testing benchmarks, this may take a while...")

    output =
      Benchee.run(
        %{
          "Generate 500 bills" => fn -> generate_and_wait(500) end
        },
        formatters: [
          Benchee.Formatters.HTML
          # Benchee.Formatters.Console
        ],
        after_scenario: fn _input -> reset_application() end
      )

    results = Enum.at(output.scenarios, 0)
    IO.puts("Average time: #{nano_to_seconds(results.run_time_data.statistics.average)}")
    assert results.run_time_data.statistics.average <= seconds_to_nano(30)
  end
end
