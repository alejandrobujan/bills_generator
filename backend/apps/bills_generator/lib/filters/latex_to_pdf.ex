defmodule BillsGenerator.Filters.LatexToPdf do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({bill_id, title, user, latex}) do
    # Dont understand this dialyzer warning
    {:ok, pdf} =
      latex
      |> Iona.source()
      |> Iona.to(:pdf)

    {bill_id, title, user, pdf}
  end

  @impl StandardLeader
  def next_action(output_data),
    do: BillsGenerator.Filters.StoreInDatabase.process_filter(output_data)
end
