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

  @doc """
    ## Exemplos:
        iex> BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", [])
        %BillsGenerator.Entities.Bill{
          title: "A bill",
          purchaser: "A purchaser",
          seller: "A seller",
          products: [],
          total: nil
        }
  """
  def new(title, purchaser, seller, nil), do: new(title, purchaser, seller, [])

  def new(title, purchaser, seller, products) do
    %__MODULE__{
      title: title,
      purchaser: purchaser,
      seller: seller,
      products: products,
      total: nil
    }
  end

  @doc """
    ## Exemplos:
        iex> products = [
        ...>   BillsGenerator.Entities.Product.new("A product", 15.0,2),
        ...>   BillsGenerator.Entities.Product.new("Another product", 3.0,3)
        ...> ]
        iex> bill = BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", products)
        iex> BillsGenerator.Entities.Bill.update_total(bill)
        %BillsGenerator.Entities.Bill{
          title: "A bill",
          purchaser: "A purchaser",
          seller: "A seller",
          products: [
            %BillsGenerator.Entities.Product{
              name: "A product",
              price: 15.0,
              quantity: 2,
              total: 30.0
            },
            %BillsGenerator.Entities.Product{
              name: "Another product",
              price: 3.0,
              quantity: 3,
              total: 9.0
            }
          ],
          total: 39.0
        }
  
  """
  def update_total(%__MODULE__{products: products} = bill) do
    {updated_bill_products, total} = calculate_bill(products)
    %__MODULE__{bill | products: updated_bill_products, total: total}
  end

  @doc """
    ## Exemplos:
        iex> products = [
        ...>   BillsGenerator.Entities.Product.new("A product", 2, 15.0),
        ...>   BillsGenerator.Entities.Product.new("Another product", 3, 3.0)
        ...> ]
        iex> bill = BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", products)
        iex> BillsGenerator.Entities.Bill.validate(bill)
        :ok
  """
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

  defp calculate_bill([]), do: {[], 0}

  defp calculate_bill(products), do: do_calculate_bill([], products, 0)

  defp do_calculate_bill(acc, [], total), do: {Enum.reverse(acc), total}

  defp do_calculate_bill(acc, [product | t], total) do
    updated_product = Product.update_total(product)

    do_calculate_bill(
      [updated_product | acc],
      t,
      total + updated_product.total
    )
  end

  defp validate_title(title) when is_bitstring(title) do
    if String.length(title) > 0 do
      :ok
    else
      {:error, "Title can't be empty."}
    end
  end

  defp validate_title(title) do
    {:error, "Incorrect title value '#{title}'. Title must be a string."}
  end

  defp validate_purchaser(purchaser) when is_bitstring(purchaser) do
    if String.length(purchaser) > 0 do
      :ok
    else
      {:error, "Purchaser can't be empty."}
    end
  end

  defp validate_purchaser(purchaser) do
    {:error, "Incorrect purchaser value '#{purchaser}'. Purchaser must be a string."}
  end

  defp validate_seller(seller) when is_bitstring(seller) do
    if String.length(seller) > 0 do
      :ok
    else
      {:error, "Seller can't be empty."}
    end
  end

  defp validate_seller(seller) do
    {:error, "Incorrect seller value '#{seller}'. Seller must be a string."}
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
      {:error, "Products list can't be empty."}
    end
  end

  defp validate_products(products) do
    {:error, "Incorrect products value '#{products}'. Products must be a list of products."}
  end
end
