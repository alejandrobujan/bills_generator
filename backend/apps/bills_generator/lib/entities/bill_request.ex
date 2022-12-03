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

  def validate(%__MODULE__{user: user, bill: bill, config: config}) do
    # returns only the first error that is found
    with :ok <- validate_user(user),
         :ok <- Bill.validate(bill),
         :ok <- BillConfig.validate(config) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_user(user) when is_bitstring(user) do
    if String.length(user) > 0 do
      :ok
    else
      {:error, "User can't be empty."}
    end
  end

  defp validate_user(user) do
    {:error, "Incorrect user value `#{user}`. User must be a string."}
  end
end
