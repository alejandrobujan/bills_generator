defmodule BillsGeneratorWeb.Router do
  use BillsGeneratorWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", BillsGeneratorWeb do
    pipe_through(:api)
    post("/bills", BillController, :generate)
    get("/bills/:id", BillController, :download)
    get("/bills", BillController, :get)
    get("/bills/:id/available", BillController, :download_available?)
  end
end
