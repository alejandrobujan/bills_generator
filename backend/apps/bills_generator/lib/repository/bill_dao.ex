defmodule BillsGenerator.Repository.BillDao do
  @moduledoc """
  Módulo que encapsula as operacións de acceso á base de datos para as facturas.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "bill" do
    field(:user, :string)
    field(:title, :string)
    field(:pdf, :binary)
    field(:error, :boolean, default: false)
    field(:error_msg, :string)

    timestamps()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:user, :title, :pdf, :error, :error_msg])
  end
end
