defmodule Leaders.Leader1 do
  alias Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def get_worker_module(), do: Filters.Filter1
  @impl StandardLeader
  def next_action(output_data), do: Leaders.Leader2.process_filter(output_data)
end
