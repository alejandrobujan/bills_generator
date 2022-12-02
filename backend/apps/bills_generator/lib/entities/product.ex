defmodule BillsGenerator.Entities.Product do
  @moduledoc """
  Módulo que encapsula o struct que representa un produto na factura.
  """
  defstruct [:name, :price, :quantity, :total]

  @typedoc """
  Struct que representa un produto na factura.
  """
  @type t :: %__MODULE__{
          name: String.t(),
          price: float(),
          quantity: integer(),
          total: nil | float()
        }
end
