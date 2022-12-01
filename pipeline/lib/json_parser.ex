defmodule JSONParser do
  alias Hex.Crypto.PBES2_HMAC_SHA2
  use GenServer
  require Logger

  @spec start_link(list) :: {:ok, pid()}
  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec stop() :: :ok
  def stop() do
    GenServer.stop(__MODULE__)
  end

  @spec parse(String.t()) :: {:ok, :ok}
  def parse(json_bill) do
    {:ok, GenServer.cast(__MODULE__, {:parse, json_bill})}
  end

  # GenServer callbacks

  @impl true
  def init(_init_arg) do
    Logger.info("[JSONParser] GenServer JSONParser initialized")
    {:ok, []}
  end

  @impl true
  def handle_cast({:parse, json_bill}, data) do
    Logger.info("[JSONParser] Piped to BillCalculator filter")
    BillCalculator.calc(parse_json(json_bill))
    {:noreply, [json_bill | data]}
  end

  # Private functions

  defp parse_json(json_bill), do: Poison.decode!(json_bill, as: %BillRequest{bill: %Bill{lines: [%BillLine{product: %Product{}}]}, config: %BillConfig{}})


end
