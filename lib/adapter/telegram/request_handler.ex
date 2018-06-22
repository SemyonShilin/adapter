defmodule Adapter.Telegram.RequestHandler do
  @moduledoc false

  use Agala.Chain.Builder
  use Agala.Provider.Telegram, :handler
  alias Agala.Conn
  alias Adapter.Telegram.MessageSender
  alias Adapter.Telegram.Model.{InlineKeyboardMarkup, InlineKeyboardButton}
  alias Agala.Provider.Telegram.Model.{Message}

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
    request_bot_params: %Agala.BotParams{name: name, storage: storage, provider_params: %{token: token}} = bot_params,
    request: request} = conn, _opts) do
    log(request)

    bot = storage.get(bot_params, :bot)
    %{"data" => response} =
      %{data: request}
      |> Map.merge(%{platform: "telegram", uid: bot.uid})
      |> call_hub()

    storage.set(bot_params, :response, response)

    conn
  end

  def parse_hub_response_handler(%Conn{request_bot_params: %{storage: storage} = bot_params, request: request} = conn, _opts) do
    message =
      storage.get(bot_params, :response)
        |> Map.get("messages", [])
        |> parse_hub_response(get_chat(request))
        |> Enum.filter(& &1)
    storage.set(bot_params, :messages, message)

    conn
  end

  def delivery_hub_response_handler(%Conn{request_bot_params: %{storage: storage} = bot_params} = conn, _opts) do
    conn |> MessageSender.delivery(storage.get(bot_params, :messages))
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

  defp parse_hub_response(messages, chat) do
    parse_hub_response(messages, chat, [])
  end

  defp parse_hub_response([message | tail] = all, chat, formatted_messages) do
    messages =
      Enum.reduce message, %{}, fn {k, v}, acc ->
        case k do
          "body" -> Map.put(acc, :text, v)
          "menu" ->
            with %{"type" => type} <- v do
              case type do
                "inline"   -> Map.put(acc, :reply_markup, InlineKeyboardMarkup.make!(%{inline_keyboard: format_menu_item(v)}))
                "keyboard" -> ""
                "auth"     -> ""
                _          -> ""
              end
            end
          _ -> ""
        end
      end

    parse_hub_response(tail, chat, [messages | formatted_messages])
  end

  defp parse_hub_response([], chat, updated_messages), do: updated_messages |> Enum.reverse

  defp format_menu_item(%{"items" => items}), do: format_menu_item(items, [])

  defp format_menu_item([%{"url" => url} = menu_item | tail], state) do
    new_state = [[InlineKeyboardButton.make!(%{text: menu_item["name"], url: url})]| state]
    format_menu_item(tail, new_state)
  end

  defp format_menu_item([%{"code" => code} = menu_item | tail], state) do
    new_state = [[InlineKeyboardButton.make!(%{text: menu_item["name"], callback_data: code})] | state]
    format_menu_item(tail, new_state)
  end

  defp format_menu_item([], state), do: state |> Enum.reverse

  defp log(%{message: %{text: text, from: %{first_name: first_name, id: user_telegrma_id}}} = request) do
    IO.puts "#{first_name} #{user_telegrma_id} : #{text}"
  end

  defp log(%{callback_query: %{data: data, from: %{first_name: first_name, id: user_telegrma_id}}} = request) do
    IO.puts "#{first_name} #{user_telegrma_id} : button - #{data}"
  end

  defp get_chat(%{message: %{chat: chat}}), do: chat

  defp get_chat(%{callback_query: %{message: %{chat: chat}}}), do: chat
end