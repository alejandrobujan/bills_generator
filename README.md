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

Quien escribe en la base de datos? Tener un nuevo último filtro en el que el worker
sea quien escriba en la base de datos, o el último líder (compilación de latex)
sea el que escriba el output
