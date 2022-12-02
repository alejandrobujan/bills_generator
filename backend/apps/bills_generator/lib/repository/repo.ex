defmodule BillsGenerator.Repository.Repo do
  use Ecto.Repo,
    otp_app: :bills_generator,
    adapter: Ecto.Adapters.Postgres
end
