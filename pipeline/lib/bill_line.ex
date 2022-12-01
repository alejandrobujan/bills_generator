defmodule BillLine do
  @moduledoc """
  Módulo que encapsula o struct que representa unha liña da factura.
  """
  defstruct [:product, :quantity, :price]
  @typedoc """
  Struct que representa unha liña da factura.
  """
  @type t :: %__MODULE__{
    product: Product.t(),
    quantity: integer(),
    price: nil | float()
}
end
