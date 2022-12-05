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
          price: number(),
          quantity: number(),
          total: nil | number()
        }

  @doc """
    ## Exemplos:
        iex> BillsGenerator.Entities.Product.new("A product", 10.0, 2)
        %BillsGenerator.Entities.Product{
          name: "A product",
          price: 10.0,
          quantity: 2,
          total: nil
        }
  """
  def new(name, price, quantity) do
    %__MODULE__{name: name, price: price, quantity: quantity, total: nil}
  end

  @doc """
  Actualiza o total do produto e devolve unha tupla co producto e o total.

    ## Exemplos:
        iex> product = BillsGenerator.Entities.Product.new("A product", 10.0, 2)
        iex> product = BillsGenerator.Entities.Product.update_total(product)
        iex> product
        %BillsGenerator.Entities.Product{
          name: "A product",
          price: 10.0,
          quantity: 2,
          total: 20.0
        }
  """
  @spec update_total(t()) :: t()
  def update_total(product) do
    %__MODULE__{product | total: calculate_total(product)}
  end

  @doc """
  Valida o producto e devolve ':ok' se o producto é válido ou unha tupla
  con '{:error, reason}' se o producto non é válido.

  ## Exemplos:
      iex> product = BillsGenerator.Entities.Product.new("A product", 10.0, 2)
      iex> BillsGenerator.Entities.Product.validate(product)
      :ok
  """
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

  def validate(_), do: {:error, "Incorrect product value. Not a Product type."}

  defp calculate_total(%__MODULE__{price: price, quantity: quantity}) do
    price * quantity
  end

  defp validate_name(name) when is_bitstring(name) do
    if String.length(name) > 0 do
      :ok
    else
      {:error, "Product name can't be empty."}
    end
  end

  defp validate_name(name) do
    {:error, "Incorrect product name value '#{name}'. Product name must be a string."}
  end

  defp validate_price(price) when is_number(price) do
    if price >= 0 do
      :ok
    else
      {:error, "Product price must be greater or equal than 0."}
    end
  end

  defp validate_price(price) do
    {:error, "Incorrect product price value '#{price}'. Product price must be a number."}
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
    {:error, "Incorrect product quantity value '#{quantity}'. Product quantity must be a number."}
  end
end
