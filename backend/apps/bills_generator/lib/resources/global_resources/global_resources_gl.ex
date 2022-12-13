defmodule GlobalResourcesGL do
  @resources %{
    purchaser: "Comprador",
    seller: "Vendedor",
    taxes: "Impostos",
    product: "Produto",
    quantity: "Cantidade",
    price: "Prezo",
    discount: "Desconto",
    amount: "Importe",
    total_before_taxes: "Total antes de impostos",
    total: "Total",
    sealorsignature: "Selo ou sinatura"
  }

  def get_resources, do: @resources
end
