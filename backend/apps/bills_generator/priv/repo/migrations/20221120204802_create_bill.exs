defmodule BillsGenerator.Repo.Migrations.CreateBill do
  use Ecto.Migration

  def change do
    create table(:bill) do
      add(:user, :string)
      add(:pdf, :binary)

      timestamps()
    end
  end
end
