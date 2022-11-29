defmodule BillsGeneratorWeb.BillController do
  use Phoenix.Controller
  alias BillsGenerator.Product
  alias BillsGenerator.{Bill, Repo}
  import Ecto.Query, only: [from: 2]

  def generate(conn, body) do
    user = body["user"]
    bill = body["bill"]

    products =
      bill["products"]
      |> Enum.map(fn item ->
        {%Product{name: item["name"], price: item["price"]}, item["quantity"]}
      end)

    seller = bill["seller"]
    purchaser = bill["purchaser"]
    title = bill["title"]
    # Pass the bill throught all filters, or just create it at the last worker?
    # In this way, we can track
    bill_id = BillsGenerator.Application.generate_bill(title, user, products, seller, purchaser)

    conn |> json(%{id: bill_id})
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

  def get_all(conn, %{"user" => user}) do
    bills =
      Repo.all(from(b in Bill, select: {b.id, b.title}, where: b.user == ^user))
      |> Enum.map(fn {id, title} -> %{id: id, title: title} end)

    json(conn, %{bills: bills})
  end

  def get_all(conn, _params) do
    conn |> send_resp(400, "Bad request, must specify an user")
  end
end
