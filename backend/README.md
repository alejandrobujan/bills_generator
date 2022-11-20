# GeneracionFacturas

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `generacion_facturas` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:generacion_facturas, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/generacion_facturas>.

# Dudas

Quién escribe en la base
de datos? el worker que genera el latex? Otro filtro nuevo en el que
el worker solamente lo escriba? o el líder del worker que genera el latex?

# To do

Las facturas están bugeadas si la tabla es muy grande,
no se rompe entre páginas.

# Notas

Para que se creen más workers del formatter y del bill calculator, las facturas tienen que tener muchos items. Por ejemplo, 1000 items.

Idea para lo de la base de datos:
el phoenix inserta una nueva factura con el esquema de ecto,
pero con el campo de pdf a null. Al hacer esto, se devuelve
la factura con el campo ID autogenerado por ecto. Luego, hay que
ir pasando esta factura vacía a los filtros, ya que en el último filtro
se tendría que escribir en la base de datos con ese ID.
Así, en el frontend podemos poner que la factura aún no está disponible si
tiene el campo pdf a null en la base de datos. Quién escribe en la base
de datos, el worker que genera el latex? Otro filtro nuevo que solamente
lo escriba? o el líder del worker que genera el latex?

# Testing

```elixir
list = [{%Product{name: "iPhone 14 Pro", price: 1319.99}, 1},
    {%Product{name: "Chocolate", price: 1.20}, 2},
    {%Product{name: "Butter", price: 3.50}, 1},
    {%Product{name: "Spaghetti", price: 0.85}, 2},
    {%Product{name: "Tuna", price: 1.50}, 3},
    {%Product{name: "Rice", price: 1.00}, 2},
    {%Product{name: "Tomato Sauce", price: 1.20}, 2},
    {%Product{name: "Orange Juice", price: 2.50}, 1},
    {%Product{name: "Milk", price: 0.90}, 6},
    {%Product{name: "Bread", price: 0.50}, 2},
    {%Product{name: "Ice Cream", price: 5.00}, 1},
    {%Product{name: "Pizza", price: 2.80}, 3},
    {%Product{name: "Cookies", price: 2.10}, 2},
    {%Product{name: "Peas", price: 1.00}, 1}]
seller = "Sainsbury's, 15-17 Tottenham Ct Rd, London W1T 1BJ, UK"
purchaser = "John Smith, 7 Horsefair Green, Otterbourne SO21 1GN, UK"
1..1000 |> Enum.each(fn _x -> Filters.BillCalculator.process_filter({list,seller,purchaser})end)

```
