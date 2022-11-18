defmodule IntegrationTest do
  use ExUnit.Case

  setup do
    BillCalculator.start_link([])
    LaTeXFormatter.start_link([])
    LaTeXToPdf.start_link([])

    on_exit(fn ->
      try do
        BillCalculator.stop()
      catch
        :exit, {:noproc, _} -> :ok
      end

      try do
        LaTeXFormatter.stop()
      catch
        :exit, {:noproc, _} -> :ok
      end

      try do
        LaTeXToPdf.stop()
      catch
        :exit, {:noproc, _} -> :ok
      end
    end)
  end

  test "file creation" do

    initial_file_count = Enum.count(Path.wildcard("out/*"))
    seller = "Sainsbury's, 15-17 Tottenham Ct Rd, London W1T 1BJ, UK"
    purchaser = "John Smith, 7 Horsefair Green, Otterbourne SO21 1GN, UK"
    items = [{%Product{name: "Rice", price: 1.00}, 2},
    {%Product{name: "Tomato Sauce", price: 1.20}, 2},
    {%Product{name: "Ice Cream", price: 5.00}, 1},
    {%Product{name: "Pizza", price: 2.80}, 3},
    {%Product{name: "Peas", price: 1.00}, 1}]

    BillGenerator.Application.generate(items, seller, purchaser)
    Process.sleep(2000)

    current_file_count = Enum.count(Path.wildcard("out/*"))

    assert current_file_count == initial_file_count + 1
  end
end
