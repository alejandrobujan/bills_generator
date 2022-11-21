defmodule BillsGeneratorWeb.BillController do
  use Phoenix.Controller
  alias BillsGenerator.Product
  alias BillsGenerator.{Bill, Repo}
  import Ecto.Query, only: [from: 2]

  def generate(conn, body) do
    products =
      body["items"]
      |> Enum.map(fn item ->
        {%Product{name: item["product"]["name"], price: item["product"]["price"]},
         item["quantity"]}
      end)

    seller = body["seller"]
    purchaser = body["purchaser"]
    user = body["user"]
    # Pass the bill throught all filters, or just create it at the last worker?
    # In this way, we can track
    BillsGenerator.Application.generate_bill(user, products, seller, purchaser)

    conn |> send_resp(200, "ok")
  end

  def download(conn, %{"id" => id}) do
    bill =
      case Repo.get(Bill, id) do
        nil -> conn |> send_resp(404, "Not found")
        bill -> bill
      end

    pdf =
      case bill.pdf do
        nil -> conn |> send_resp(404, "Not found")
        pdf -> pdf
      end

    conn |> send_download({:binary, pdf}, filename: "bill.pdf")
  end

  def download_available?(conn, %{"id" => id}) do
    bill =
      case Repo.get(Bill, id) do
        nil -> conn |> send_resp(404, "Not found")
        bill -> bill
      end

    conn |> json(%{available: bill.pdf != nil})
  end

  def get(conn, %{"user" => user}) do
    bills =
      Repo.all(from(b in Bill, select: {b.id, b.user}, where: b.user == ^user))
      |> Enum.map(fn {id, user} -> %{id: id, user: user} end)

    json(conn, %{bills: bills})
  end

  def get(conn, _params) do
    bills =
      Repo.all(from(b in Bill, select: {b.id, b.user}))
      |> Enum.map(fn {id, user} -> %{id: id, user: user} end)

    json(conn, %{bills: bills})
  end
end
