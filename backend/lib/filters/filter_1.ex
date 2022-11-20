defmodule Filters.Filter1 do
  alias Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action(message), do: message <> " -> Filter1"

  @impl StandardLeader
  def next_action(output_data), do: Filters.Filter2.process_filter(output_data)
end
