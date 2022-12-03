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

  def validate(%__MODULE__{title: title, purchaser: purchaser, seller: seller, products: products}) do
    # returns only the first error that is found
    with :ok <- validate_title(title),
         :ok <- validate_purchaser(purchaser),
         :ok <- validate_seller(seller),
         :ok <- validate_products(products) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_title(title) when is_bitstring(title) do
    if String.length(title) > 0 do
      :ok
    else
      {:error, "Title can't be empty."}
    end
  end

  defp validate_title(title) do
    {:error, "Incorrect title value `#{title}`. Title must be a string."}
  end

  defp validate_purchaser(purchaser) when is_bitstring(purchaser) do
    if String.length(purchaser) > 0 do
      :ok
    else
      {:error, "Purchaser can't be empty."}
    end
  end

  defp validate_purchaser(purchaser) do
    {:error, "Incorrect purchaser value `#{purchaser}`. Purchaser must be a string."}
  end

  defp validate_seller(seller) when is_bitstring(seller) do
    if String.length(seller) > 0 do
      :ok
    else
      {:error, "Seller can't be empty."}
    end
  end

  defp validate_seller(seller) do
    {:error, "Incorrect seller value `#{seller}`. Seller must be a string."}
  end

  defp validate_products(products) when is_list(products) do
    if length(products) > 0 do
      # If there are products, validate each one
      Enum.reduce_while(products, :ok, fn product, _acc ->
        case Product.validate(product) do
          :ok -> {:cont, :ok}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    else
      {:error, "Products can't be empty."}
    end
  end

  defp validate_products(products) do
    {:error, "Incorrect products value `#{products}`. Products must be a list."}
  end
end
