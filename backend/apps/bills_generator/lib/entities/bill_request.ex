defmodule BillsGenerator.Entities.BillRequest do
  alias BillsGenerator.Entities.{Bill, BillConfig}

  @moduledoc """
  Módulo que encapsula o struct que representa unha solicitude de factura.
  """
  defstruct [:user, :bill, :config]

  @typedoc """
  Struct que representa unha solicitude de factura.
  """
  @type t :: %__MODULE__{
          user: String.t(),
          bill: Bill.t(),
          config: BillConfig.t()
        }
end
