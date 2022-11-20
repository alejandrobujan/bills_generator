defmodule Product do
  @moduledoc """
  Módulo que encapsula o struct que representa un produto na factura.
  """
  defstruct [:name, :price]
  @typedoc """
  Struct que representa un produto na factura.
  """
  @type t :: %__MODULE__{
    name: nil | String.t,
    price: float()
}
end
