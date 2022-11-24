defmodule BillsGenerator.Filters.LatexToPdf do
  alias BillsGenerator.Core.StandardLeader
  use StandardLeader

  @impl StandardLeader
  def worker_action({stored_bill, latex}) do
    filename = generate_filename()
    if !File.exists?("out/"), do: File.mkdir("out/")
    # Iona.source(latex) |> Iona.write!(filename)

    {:ok, pdf} =
      latex
      |> Iona.source()
      |> Iona.to(:pdf)

    stored_bill |> Ecto.Changeset.change(pdf: pdf) |> BillsGenerator.Repo.update!()

    filename
  end

  @impl StandardLeader
  def next_action(output_data), do: IO.puts("PDF generated in #{output_data}")

  # Private functions

  defp generate_filename() do
    {{y, mon, d}, {h, min, s}} = :calendar.local_time()
    "out/bill-#{y}-#{mon}-#{d}-#{h}-#{min}-#{s}.pdf"
  end
end