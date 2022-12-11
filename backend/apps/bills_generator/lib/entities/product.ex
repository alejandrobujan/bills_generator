defmodule BillsGenerator.Entities.Product do
  @moduledoc """
  Módulo que encapsula o struct que representa un produto na factura.
  """
  defstruct [:name, :price, :quantity, :discount, :discounted_amount, :total]

  @typedoc """
  Struct que representa un produto na factura.
  """
  @type t :: %__MODULE__{
          name: String.t(),
          price: number(),
          quantity: number(),
          discount: nil | number(),
          discounted_amount: nil | number(),
          total: nil | number()
        }

  @doc """
    ## Exemplos:
        iex> BillsGenerator.Entities.Product.new("A product", 10.0, 2)
        %BillsGenerator.Entities.Product{
          name: "A product",
          price: 10.0,
          quantity: 2,
          discount: nil,
          discounted_amount: nil,
          total: nil
        }
  """
  def new(name, price, quantity, discount \\ nil) do
    %__MODULE__{name: name, price: price, quantity: quantity, discount: discount, discounted_amount: nil, total: nil}
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
          discount: nil,
          discounted_amount: 0,
          total: 20.0
        }
  """
  @spec update_total(t()) :: t()
  def update_total(product) do
    total = calculate_total(product)
    disc_amount = calculate_discount(product, total)
    %__MODULE__{product | discounted_amount: disc_amount, total: total - disc_amount}
  end

  @doc """
  Valida o producto e devolve ':ok' se o producto é válido ou unha tupla
  con '{:error, reason}' se o producto non é válido.

  ## Exemplos:
      iex> product = BillsGenerator.Entities.Product.new("A product", 10.0, 2, 5)
      iex> BillsGenerator.Entities.Product.validate(product)
      :ok
  """
  def validate(%__MODULE__{name: name, price: price, quantity: quantity, discount: discount}) do
    # returns only the first error that is found
    with :ok <- validate_name(name),
         :ok <- validate_price(price),
         :ok <- validate_quantity(quantity),
         :ok <- validate_discount(discount) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def validate(_), do: {:error, "Incorrect product value. Not a Product type."}

  defp calculate_total(%__MODULE__{price: price, quantity: quantity}) do
    price * quantity
  end

  defp calculate_discount(%__MODULE__{discount: nil}, total),
    do: 0

  defp calculate_discount(%__MODULE__{discount: discount}, total) do
    (discount / 100) * total
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

  defp validate_discount(discount) when is_nil(discount),
    do: :ok

  defp validate_discount(discount) when is_number(discount) do
    if discount >= 0 and discount <= 100 do
      :ok
    else
      {:error, "Product discount must be greater or equal than 0."}
    end
  end

  defp validate_discount(discount) do
    {:error, "Incorrect discount value '#{discount}'. Product discount must be a number or nill."}
  end
end
