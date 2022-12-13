defmodule GlobalResourcesES do
  @resources %{
    purchaser: "Comprador",
    seller: "Vendedor",
    taxes: "Impuestos",
    product: "Producto",
    quantity: "Cantidad",
    price: "Precio",
    discount: "Descuento",
    amount: "Importe",
    total_before_taxes: "Total antes de impuestos",
    total: "Total",
    sealorsignature: "Sello o firma"
  }

  def get_resources, do: @resources
end
