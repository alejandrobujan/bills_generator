defmodule BillsGenerator.Repository.Bill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bill" do
    field(:user, :string)
    field(:title, :string)
    field(:pdf, :binary)

    timestamps()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:user, :title])
    |> validate_required([:user, :title])
  end
end
