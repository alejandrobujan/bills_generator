defmodule BillsGeneratorWeb.Router do
  use BillsGeneratorWeb, :router

  pipeline :api_parsing do
    plug(Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()
    )

    plug(:accepts, ["json"])
  end

  scope "/api", BillsGeneratorWeb do
    post("/bills", BillController, :generate)
    # Do not pipe generate bills throught json parsers, since we will do it in the pipeline.

    pipe_through(:api_parsing)
    get("/bills", BillController, :get_all)
    get("/bills/:id/download", BillController, :download)
    get("/bills/:id", BillController, :get)
    get("/bills/:id/available", BillController, :download_available?)
  end
end
