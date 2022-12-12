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

  @available_currencies ["euro", "dollar"]

  @available_languages ["en", "es", "gl"]

  defstruct font_size: 10,
            font_style: "latex",
            paper_size: "a4paper",
            landscape: false,
            currency: "euro",
            language: "en"

  @typedoc """
  Struct que representa os parámetros de configuración dunha factura.
  """
  @type t :: %__MODULE__{
          font_size: non_neg_integer(),
          font_style: String.t(),
          paper_size: String.t(),
          landscape: boolean(),
          currency: String.t(),
          language: String.t()
        }

  @doc """
    ## Exemplos:
        iex> BillsGenerator.Entities.BillConfig.new(11,"latex","a4paper",true,"euro")
        %BillsGenerator.Entities.BillConfig{
          font_size: 11,
          font_style: "latex",
          paper_size: "a4paper",
          landscape: true,
          currency: "euro"
        }
  """
  def new(
        font_size \\ 10,
        font_style \\ "latex",
        paper_size \\ "a4paper",
        landscape \\ false,
        currency \\ "euro",
        language \\ "en"
      ) do
    %__MODULE__{
      font_size: font_size,
      font_style: font_style,
      paper_size: paper_size,
      landscape: landscape,
      currency: currency,
      language: language
    }
  end

  @doc """
  Valida a configuración da factura e devolve ':ok' se a configuración é válida ou unha tupla
  con '{:error, reason}' se a configuración non é válida.

  ## Exemplos:
      iex> config = BillsGenerator.Entities.BillConfig.new(11,"latex","a4paper",true,"euro")
      iex> BillsGenerator.Entities.BillConfig.validate(config)
      :ok
  """
  def validate(%__MODULE__{
        font_size: font_size,
        font_style: font_style,
        paper_size: paper_size,
        landscape: landscape,
        currency: currency,
        language: language
      }) do
    # returns only the first error that is found
    with :ok <- validate_font_size(font_size),
         :ok <- validate_font_style(font_style),
         :ok <- validate_paper_size(paper_size),
         :ok <- validate_landscape(landscape),
         :ok <- validate_currency(currency),
         :ok <- validate_language(language) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_font_size(font_size) when is_number(font_size) do
    if font_size in @available_font_sizes do
      :ok
    else
      {:error,
       "Font size '#{font_size}' not supported. Available font sizes are: #{Enum.join(@available_font_sizes, ", ")}."}
    end
  end

  defp validate_font_size(font_size) do
    {:error, "Incorrect font size value '#{font_size}'. Font size must be a number."}
  end

  defp validate_font_style(font_style) when is_bitstring(font_style) do
    if font_style in @available_font_styles do
      :ok
    else
      {:error,
       "Font style '#{font_style}' not supported. Available font styles are: #{Enum.join(@available_font_styles, ", ")}."}
    end
  end

  defp validate_font_style(font_style) do
    {:error, "Incorrect font style value '#{font_style}'. Font Style must be a string."}
  end

  defp validate_paper_size(paper_size) when is_bitstring(paper_size) do
    if paper_size in @available_paper_sizes do
      :ok
    else
      {:error,
       "Paper size '#{paper_size}' not supported. Available paper sizes are: #{Enum.join(@available_paper_sizes, ", ")}."}
    end
  end

  defp validate_paper_size(paper_size) do
    {:error, "Incorrect paper size value '#{paper_size}'. Paper size must be a string."}
  end

  defp validate_landscape(landscape) when is_boolean(landscape), do: :ok

  defp validate_landscape(landscape),
    do: {:error, "Incorrect landscape value '#{landscape}'. Landscape must be a boolean."}

  defp validate_currency(currency) when is_bitstring(currency) do
    if currency in @available_currencies do
      :ok
    else
      {:error,
       "Currency '#{currency}' not supported. Available currencies are: #{Enum.join(@available_currencies, ", ")}."}
    end
  end

  defp validate_currency(currency),
    do: {:error, "Incorrect currency value '#{currency}'. Currency must be a string."}

  defp validate_language(language) when is_bitstring(language) do
    if language in @available_languages do
      :ok
    else
      {:error,
       "Language '#{language}' not supported. Available languages are: #{Enum.join(@available_languages, ", ")}."}
    end
  end

  defp validate_language(language),
    do: {:error, "Incorrect language value '#{language}'. Language must be a string."}
end
