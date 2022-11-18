defmodule Services.Service1 do
  @moduledoc """
  Servizo de exemplo que implementa o comportamento `Core.StandardServer`.
  Tarda 1 segundo en responder ás peticións.
  """
  alias Core.StandardServer
  use StandardServer

  @delay_time 1_000

  @impl StandardServer
  def handle_get() do
    Process.sleep(@delay_time)
    "Im Service1"
  end
end
