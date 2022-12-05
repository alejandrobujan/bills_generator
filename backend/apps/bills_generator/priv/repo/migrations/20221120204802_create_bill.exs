defmodule BillsGenerator.Repository.Repo.Migrations.CreateBill do
  use Ecto.Migration

  def change do
    create table(:bill) do
      add(:user, :string)
      add(:title, :text)
      add(:pdf, :binary)
      add(:error, :boolean)
      add(:error_msg, :text)
      timestamps()
    end
  end
end
