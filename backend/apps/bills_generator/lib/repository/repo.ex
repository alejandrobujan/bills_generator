defmodule BillsGenerator.Repository.Repo do
  @moduledoc """
  Módulo que encapsula a conexión coa base de datos.
  """

  use Ecto.Repo,
    otp_app: :bills_generator,
    adapter: Ecto.Adapters.Postgres
end
