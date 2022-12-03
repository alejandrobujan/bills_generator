defmodule BillsGeneratorWeb.BillController do
  use Phoenix.Controller
  alias BillsGenerator.Entities.Product
  alias BillsGenerator.Repository
  import Ecto.Query, only: [from: 2]
  # This module is a service one, but using phoenix naming,
  # it should be called controller

  # We have parsers plug deactivated, so
  def generate(conn, params) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    bill_id = BillsGenerator.Application.generate_bill(body)

    conn |> json(%{id: bill_id})
  end

  def get(conn, %{"id" => id}) do
    bill = Repository.Repo.get!(Repository.Bill, id)

    # TODO: change created_at to updated_at?
    bill_map = %{
      id: bill.id,
      user: bill.user,
      title: bill.title,
      is_available: bill.pdf != nil,
      error: bill.error,
      error_msg: bill.error_msg,
      created_at: bill.updated_at
    }

    conn |> json(bill_map)
  end

  def download(conn, %{"id" => id}) do
    bill =
      case Repository.Repo.get(Repository.Bill, id) do
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
      Repository.Repo.all(
        from(b in Repository.Bill,
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
          created_at: updated_at
        }
      end)

    json(conn, %{bills: bills})
  end

  def get_all(conn, _params) do
    conn |> send_resp(400, "Bad request, must specify an user")
  end
end
