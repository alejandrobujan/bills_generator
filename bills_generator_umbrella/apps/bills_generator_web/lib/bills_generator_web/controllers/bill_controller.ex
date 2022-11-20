defmodule BillsGeneratorWeb.BillController do
  use Phoenix.Controller
  alias BillsGenerator.Product
  alias BillsGenerator.Filters.BillCalculator

  def generate(conn, body) do
    products =
      body["items"]
      |> Enum.map(fn item ->
        {%Product{name: item["product"]["name"], price: item["product"]["price"]},
         item["quantity"]}
      end)

    seller = body["seller"]
    purchaser = body["purchaser"]

    BillCalculator.process_filter({products, seller, purchaser})
  end
end
