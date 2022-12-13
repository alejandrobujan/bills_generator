defmodule GlobalResources do
  @resources %{
    purchaser: "Purchaser",
    seller: "Seller",
    taxes: "Taxes",
    product: "Product",
    quantity: "Quantity",
    price: "Price",
    discount: "Discount",
    amount: "Amount",
    total_before_taxes: "Total before taxes",
    total: "Total",
    sealorsignature: "Seal or signature"
  }

  def get_resources, do: @resources
end
