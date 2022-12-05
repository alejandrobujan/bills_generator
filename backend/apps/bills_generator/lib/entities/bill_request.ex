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

  @doc """
  Crea unha nova solicitude de factura.
  
    ## Exemplos
      iex> user = "John Doe"
      iex> product = BillsGenerator.Entities.Product.new("A product", 15.0,2)
      iex> bill = BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", [product])
      iex> config = BillsGenerator.Entities.BillConfig.new(11,"latex","a4paper",true)
      iex> BillsGenerator.Entities.BillRequest.new(user, bill, config)
      %BillsGenerator.Entities.BillRequest{
        user: "John Doe",
        bill: %BillsGenerator.Entities.Bill{
          title: "A bill",
          purchaser: "A purchaser",
          seller: "A seller",
          products: [
            %BillsGenerator.Entities.Product{
              name: "A product",
              price: 15.0,
              quantity: 2,
              total: nil
            }
          ],
          total: nil
        },
        config: %BillsGenerator.Entities.BillConfig{
          font_size: 11,
          font_style: "latex",
          paper_size: "a4paper",
          landscape: true
        }
      }
  """
  def new(user, bill, config) do
    %__MODULE__{
      user: user,
      bill: bill,
      config: config
    }
  end

  @doc """
  Valida unha solicitude de factura.
  
    ## Exemplos
      iex> user = "John Doe"
      iex> product = BillsGenerator.Entities.Product.new("A product", 15.0,2)
      iex> bill = BillsGenerator.Entities.Bill.new("A bill", "A purchaser", "A seller", [product])
      iex> config = BillsGenerator.Entities.BillConfig.new(11,"latex","a4paper",true)
      iex> bill_request = BillsGenerator.Entities.BillRequest.new(user, bill, config)
      iex> BillsGenerator.Entities.BillRequest.validate(bill_request)
      :ok
  """
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
    {:error, "Incorrect user value '#{user}'. User must be a string."}
  end
end
