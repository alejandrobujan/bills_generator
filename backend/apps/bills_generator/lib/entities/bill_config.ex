defmodule BillsGenerator.Entities.BillConfig do
  @moduledoc """
  Módulo que encapsula o struct que representa os parámetros de configuración dunha factura.
  """
  @available_font_sizes [10, 11, 12]
  @available_font_styles ["latex", "times"]

  @available_paper_sizes [
    "a4paper",
    "a5paper",
    "b5paper",
    "letterpaper",
    "legalpaper",
    "executivepaper"
  ]

  defstruct font_size: 10, font_style: "latex", paper_size: "a4paper", landscape: false

  @typedoc """
  Struct que representa os parámetros de configuración dunha factura.
  """
  @type t :: %__MODULE__{
          font_size: non_neg_integer(),
          font_style: String.t(),
          paper_size: String.t(),
          landscape: boolean()
        }

  def is_valid?(config) do
    config.font_size in @available_font_sizes &&
      config.font_style in @available_font_styles &&
      config.paper_size in @available_paper_sizes
  end
end
