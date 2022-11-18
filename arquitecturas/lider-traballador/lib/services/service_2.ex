defmodule Services.Service2 do
  @moduledoc """
  Servizo de exemplo que implementa o comportamento `Core.StandardServer`.
  Tarda 30 segundos en responder ás peticións.
  """

  alias Core.StandardServer
  use StandardServer

  @delay_time 30_000

  @impl StandardServer
  def handle_get() do
    Process.sleep(@delay_time)
    "Im Service2"
  end
end
