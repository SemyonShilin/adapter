defmodule Adapter.Telegram.RequestHandler do
  @moduledoc false

  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler
  alias Agala.Conn
  alias Adapter.Telegram.MessageSender

  chain(Agala.Provider.Telegram.Chain.Parser)

  chain(:find_bot_handler)
  chain(:send_messege_to_hub_handler)
  chain(:delivery_hub_response_handler)
  chain(:parse_hub_response_handler)
  chain(:handle)

  def find_bot_handler(%Conn{
    request_bot_params: %Agala.BotParams{name: name, storage: storage, provider_params: %{token: token}} = bot_params} = conn,
  _opts) do
    bot = Adapter.Bots.get_by_bot(%{token: token})
    storage.set(bot_params, :bot, bot)
    conn
  end

  def send_messege_to_hub_handler(%Conn{
    request: %{message: %{text: text, from: %{first_name: first_name, id: user_telegrma_id}}} = request,
    request_bot_params: %Agala.BotParams{name: name, storage: storage, provider_params: %{token: token}} = bot_params} = conn,
  _opts) do
    IO.puts "#{first_name} #{user_telegrma_id} : #{text}"

    bot = storage.get(bot_params, :bot)
    %{"data" => response} =
      %{data: request}
      |> Map.merge(%{platform: "telegram", uid: bot.uid})
      |> call_hub()

    storage.set(bot_params, :response, response)

    conn
  end

  def parse_hub_response_handler(%Conn{request_bot_params: %Agala.BotParams{name: name, storage: storage} = bot_params} = conn, _opts) do
    storage.get(bot_params, :response)
      |> Map.get("messages", %{})
      |> parse_hub_response()

    conn
  end

  def delivery_hub_response_handler(conn, _opts) do
    conn |> MessageSender.delivery()
    conn
  end

  def handle(conn, _opts) do
    IO.puts("----> You have just received message <----")
    Conn.halt(conn)
  end

  defp call_hub(message) do
    HTTPoison.start
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post System.get_env("DCH_POST"), Poison.encode!(message), [{"Content-Type", "application/json"}]
    Poison.decode!(body)
  end

  defp parse_hub_response([message | tail]) do
    with %{"menu" => menu} <- message,
         %{"type" => type} <- menu
      do
        case type do
          "inline" -> Agala.Provider.Telegram.Model.InlineQuery.make!(message)
          "keyboard" -> ""
          "auth" -> ""
          _ -> nil
        end
    end

    %{text: message["body"], object: nil}

    parse_hub_response(tail)
  end

  defp parse_hub_response([]), do: []
end