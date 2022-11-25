defmodule BillsGenerator.Filters.Filter3 do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action(message), do: message <> " -> Filter3"

  @impl StandardLeader
  def next_action(output_data), do: IO.puts("Output: #{output_data}")
end
