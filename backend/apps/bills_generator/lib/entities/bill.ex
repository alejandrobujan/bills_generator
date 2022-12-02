defmodule BillsGenerator.Entities.Bill do
  alias BillsGenerator.Entities.Product

  @moduledoc """
  Módulo que encapsula o struct que representa unha factura.
  """
  defstruct [:title, :purchaser, :seller, :products, :total]

  @typedoc """
  Struct que representa unha factura.
  """
  @type t :: %__MODULE__{
          title: String.t(),
          purchaser: String.t(),
          seller: String.t(),
          products: list(Product),
          total: nil | float()
        }
end
