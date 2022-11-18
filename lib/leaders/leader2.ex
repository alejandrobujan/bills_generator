defmodule Leaders.Leader2 do
  alias Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def get_worker_module(), do: Filters.Filter2
  @impl StandardLeader
  def next_action(output_data), do: IO.puts("Output: #{output_data}")
end
