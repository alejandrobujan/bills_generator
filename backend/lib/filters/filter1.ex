defmodule Filters.Filter1 do
  alias Core.StandardFilter
  use StandardFilter

  @impl StandardFilter
  def do_process_filter(message) do
    message <> " -> Filter1"
  end
end
