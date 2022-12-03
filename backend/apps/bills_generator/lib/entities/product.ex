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

  def validate(%__MODULE__{name: name, price: price, quantity: quantity}) do
    # returns only the first error that is found
    with :ok <- validate_name(name),
         :ok <- validate_price(price),
         :ok <- validate_quantity(quantity) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_name(name) when is_bitstring(name) do
    if String.length(name) > 0 do
      :ok
    else
      {:error, "Product name can't be empty."}
    end
  end

  defp validate_name(name) do
    {:error, "Incorrect product name value `#{name}`. Product name must be a string."}
  end

  # Should we pass the name to this function, so the error message
  # displays to which item it refers?
  defp validate_price(price) when is_number(price) do
    if price > 0 do
      :ok
    else
      {:error, "Product price must be greater than 0"}
    end
  end

  defp validate_price(price) do
    {:error, "Incorrect product price value `#{price}`. Product price must be a number."}
  end

  # We allow float quantities, since they could mean some other unit such as
  # kilograms or liters.
  defp validate_quantity(quantity) when is_number(quantity) do
    if quantity > 0 do
      :ok
    else
      {:error, "Product quantity must be greater than 0."}
    end
  end

  defp validate_quantity(quantity) do
    {:error, "Incorrect product quantity value `#{quantity}`. Product quantity must be a number."}
  end
end
