defmodule BillsGeneratorWeb.BillController do
  use Phoenix.Controller
  alias BillsGenerator.Repository.{Repo, BillDao}
  import Ecto.Query, only: [from: 2]
  # This module is a service one, but using phoenix naming,
  # it should be called controller

  def generate(conn, _params) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    bill_id = BillsGenerator.Application.generate_bill(body)

    conn |> json(%{id: bill_id})
  end

  def get(conn, %{"id" => id}) do
    bill = Repo.get!(BillDao, id)

    bill_map = %{
      id: bill.id,
      user: bill.user,
      title: bill.title,
      is_available: bill.pdf != nil,
      error: bill.error,
      error_msg: bill.error_msg,
      created_at: DateTime.from_naive!(bill.updated_at, "Etc/UTC")
    }

    conn |> json(bill_map)
  end

  def download(conn, %{"id" => id}) do
    bill =
      case Repo.get(BillDao, id) do
        nil -> conn |> send_resp(404, "Not found")
        bill -> bill
      end

    pdf =
      case bill.pdf do
        nil -> conn |> send_resp(404, "Not found")
        pdf -> pdf
      end

    conn |> send_download({:binary, pdf}, filename: "bill-#{id}.pdf")
  end

  def get_all(conn, %{"user" => user}) do
    bills =
      Repo.all(
        from(b in BillDao,
          select: {b.id, b.title, b.pdf, b.error, b.error_msg, b.updated_at},
          where: b.user == ^user,
          order_by: [desc: b.updated_at]
        )
      )
      |> Enum.map(fn {id, title, pdf, error, error_msg, updated_at} ->
        %{
          id: id,
          user: user,
          title: title,
          is_available: pdf != nil,
          error: error,
          error_msg: error_msg,
          created_at: DateTime.from_naive!(updated_at, "Etc/UTC")
        }
      end)

    json(conn, %{bills: bills})
  end

  def get_all(conn, _params) do
    conn |> send_resp(400, "Bad request, must specify an user")
  end
end
