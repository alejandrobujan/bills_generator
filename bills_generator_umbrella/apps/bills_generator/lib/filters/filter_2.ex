defmodule BillsGenerator.Filters.Filter2 do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action(message), do: message <> " -> Filter2"

  @impl StandardLeader
  def next_action(output_data), do: BillsGenerator.Filters.Filter3.process_filter(output_data)
end
