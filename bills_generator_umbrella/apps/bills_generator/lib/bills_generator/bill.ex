defmodule BillsGenerator.Bill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bill" do
    field(:user, :string)
    field(:pdf, :binary)

    timestamps()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:user])
    |> validate_required([:user])
  end
end
