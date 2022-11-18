defmodule Filters.Filter2 do
  alias Core.StandardFilter
  use StandardFilter

  def do_process_filter(message) do
    message <> " -> Filter2"
  end
end
