defmodule BillsGenerator.Filters.LatexToPdf do
  alias BillsGenerator.Core.GenFilter
  use GenFilter

  @impl GenFilter
  def worker_action(bill_id: bill_id, bill_request: bill_request, latex: latex),
    do: [bill_id: bill_id, bill_request: bill_request, pdf: generate_pdf(latex)]

  @impl GenFilter
  def next_action(output_data),
    do: BillsGenerator.Filters.StoreInDatabase.process_filter(output_data)

  # Private functions

  defp generate_pdf(latex) do
    {:ok, pdf} =
      latex
      |> Iona.source()
      |> Iona.to(:pdf)

    pdf
  end
end
