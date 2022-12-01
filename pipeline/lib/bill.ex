defmodule Bill do
  @moduledoc """
  Módulo que encapsula o struct que representa unha factura.
  """
  defstruct [:title, :purchaser, :seller, :lines, :total]
  @typedoc """
  Struct que representa unha factura.
  """
  @type t :: %__MODULE__{
    title: String.t(),
    purchaser: String.t(),
    seller: String.t(),
    lines: list(),
    total: nil | float()
}
end
