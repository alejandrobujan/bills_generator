defmodule BillsGeneratorWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :bills_generator_web

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_bills_generator_web_key",
    signing_salt: "hUOgNlix"
  ]
  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :bills_generator_web)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  # Do not parse Json. We do that in the pipeline
  # plug Plug.Parsers,
  #   parsers: [:urlencoded, :multipart, :json],
  #   pass: ["*/*"],
  #   json_decoder: Phoenix.json_library()

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(BillsGeneratorWeb.Router)
end
