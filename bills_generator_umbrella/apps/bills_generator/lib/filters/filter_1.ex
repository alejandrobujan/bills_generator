defmodule BillsGenerator.Filters.Filter1 do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action(message), do: message <> " -> Filter1"

  @impl StandardLeader
  def next_action(output_data), do: BillsGenerator.Filters.Filter2.process_filter(output_data)
end
