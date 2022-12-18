defmodule BillsGenerator.Entities.Bill do
  alias BillsGenerator.Entities.Product

  @moduledoc """
  Módulo que encapsula o struct que representa unha factura.
  """
  defstruct [
    :title,
    :purchaser,
    :seller,
    :products,
    :total_before_taxes,
    :taxes_amount,
    :total,
    # date now as a default
    date: Date.to_iso8601(Date.from_erl!(elem(:calendar.local_time(), 0))),
    taxes: 0.0
  ]

  @typedoc """
  Struct que representa unha factura.
  """
  @type t :: %__MODULE__{
          title: String.t(),
          purchaser: String.t(),
          seller: String.t(),
          date: String.t(),
          products: list(Product),
          taxes: number(),
          total_before_taxes: nil | number(),
          taxes_amount: nil | number(),
          total: nil | number()
        }

  @doc """
    ## Exemplos:
        iex> BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", "2021-07-10", [], 20.0)
        %BillsGenerator.Entities.Bill{
          title: "A bill",
          purchaser: "A purchaser",
          seller: "A seller",
          date: "2021-07-10",
          products: [],
          taxes: 20.0,
          total_before_taxes: nil,
          taxes_amount: nil,
          total: nil
        }
  """

  def new(title, purchaser, seller, date, products, taxes) do
    %__MODULE__{
      title: title,
      purchaser: purchaser,
      seller: seller,
      date: date,
      products: products,
      taxes: taxes,
      total: nil
    }
  end

  @doc """
    ## Exemplos:
        iex> products = [
        ...>   BillsGenerator.Entities.Product.new("A product", 15.0,2),
        ...>   BillsGenerator.Entities.Product.new("Another product", 3.0,3, 10.0)
        ...> ]
        iex> bill = BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", "2021-07-10", products, 20.0)
        iex> BillsGenerator.Entities.Bill.update_total(bill)
        %BillsGenerator.Entities.Bill{
          title: "A bill",
          purchaser: "A purchaser",
          seller: "A seller",
          date: "2021-07-10",
          products: [
            %BillsGenerator.Entities.Product{
              name: "A product",
              price: 15.0,
              quantity: 2,
              discount: 0.0,
              discounted_amount: 0.0,
              total: 30.0
            },
            %BillsGenerator.Entities.Product{
              name: "Another product",
              price: 3.0,
              quantity: 3,
              discount: 10.0,
              discounted_amount: 0.9,
              total: 8.1
            }
          ],
          taxes: 20.0,
          total_before_taxes: 38.1,
          taxes_amount: 7.619999999999997,
          total: 45.72
        }
  
  """
  def update_total(%__MODULE__{products: products} = bill) do
    {updated_bill_products, total_before_taxes} = calculate_bill(products)
    total = calculate_taxes(bill.taxes, total_before_taxes)

    %__MODULE__{
      bill
      | products: updated_bill_products,
        total_before_taxes: total_before_taxes,
        taxes_amount: total - total_before_taxes,
        total: total
    }
  end

  @doc """
    ## Exemplos:
        iex> products = [
        ...>   BillsGenerator.Entities.Product.new("A product", 2, 15.0),
        ...>   BillsGenerator.Entities.Product.new("Another product", 3, 3.0, 10.0)
        ...> ]
        iex> bill = BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", "2021-07-10", products, 20.0)
        iex> BillsGenerator.Entities.Bill.validate(bill)
        :ok
  """
  def validate(%__MODULE__{
        title: title,
        purchaser: purchaser,
        seller: seller,
        date: date,
        products: products,
        taxes: taxes
      }) do
    # returns only the first error that is found
    with :ok <- validate_title(title),
         :ok <- validate_purchaser(purchaser),
         :ok <- validate_seller(seller),
         :ok <- validate_products(products),
         :ok <- validate_date(date),
         :ok <- validate_taxes(taxes) do
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

  defp calculate_taxes(taxes, total_before_taxes) do
    total_before_taxes * (1 + taxes / 100)
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

  defp validate_date(date) do
    case Date.from_iso8601(date) do
      {:ok, _} -> :ok
      {:error, :invalid_format} -> {:error, "Date must be formatted as iso8601 (yyyy-MM-dd)."}
      {:error, :invalid_date} -> {:error, "Date must be a valid date."}
    end
  end

  defp validate_taxes(taxes) when is_number(taxes) do
    if taxes >= 0 do
      :ok
    else
      {:error, "Bill taxes must be greater or equal than 0."}
    end
  end

  defp validate_taxes(taxes) do
    {:error, "Incorrect taxes value '#{taxes}'. Bill taxes must be a number."}
  end
end
