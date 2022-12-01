defmodule BillConfig do
  @moduledoc """
  Módulo que encapsula o struct que representa os parámetros de configuración dunha factura.
  """
  defstruct [font_size: "10pt", font_style: "latex", paper_size: "a4paper", landscape: false]
  @typedoc """
  Struct que representa os parámetros de configuración dunha factura.
  """
  @type t :: %__MODULE__{
    font_size: String.t(),
    font_style: String.t(),
    paper_size: String.t(),
    landscape: boolean()
  }

  def is_valid(config) do
    available_font_sizes = ["10pt", "11pt", "12pt"]
    available_font_styles = [:latex, :times]
    available_paper_sizes = [:a4paper, :a5paper, :b5paper, :letterpaper, :legalpaper, :executivepaper]
    config.font_size in available_font_sizes && String.to_atom(config.font_style) in available_font_styles && String.to_atom(config.paper_size) in available_paper_sizes
  end
end
