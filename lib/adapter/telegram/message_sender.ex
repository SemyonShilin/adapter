defmodule Adapter.Telegram.MessageSender do
  @moduledoc """
  Module for sending messages to telegram
  """

  alias Agala.Provider.Telegram.Helpers
  alias Agala.Conn
  alias Agala.BotParams

#  def delivery(state, %{"data" => data} = message) do
#    IO.inspect state
#    IO.inspect message
#
#    IO.inspect "11111111111111"
#    IO.inspect data
#  end

  def delivery(%Conn{request_bot_params: bot_params} = conn, messages) when is_list(messages) do
    %{request: %{message: %{chat: %{id: id}}}} = conn

    messages
    |> Enum.each fn message ->
      answer(bot_params, id, message)
    end
  end

  def delivery(_conn, _messages) do
    nil
  end

  def answer(%BotParams{name: bot_name, provider_params: %{token: token}} = params, telegram_user_id, %{text: text, reply_markup: reply_markup} = message) do
    # Function for sending response to bot
    IO.inspect reply_markup
    Agala.response_with(
      %Agala.Conn{request_bot_params: params} |> Agala.Conn.send_to(bot_name) # You must explicitly specify bot name.
      |> Helpers.send_message(telegram_user_id, text, [reply_markup: reply_markup]) # Helper function for telegram prpovider.
      |> Conn.with_fallback(&message_fallback(&1)) # Fallback after successful request sending. Pass Agala.Conn.t of finished request.
      # It is not necessary to pass fallback. It's just mechanism to make feedback after sending message.
      # For example it is necessary to display that message has been delivered. Or there could become error or something else.
    )
  end

  def answer(%Conn{request_bot_params: %{name: bot_name}, request: %{message: %{from: %{ id: user_telegrma_id}}}} = _conn, message) do
    # Function for sending response to bot
    IO.inspect message
    Agala.response_with(
      %Agala.Conn{} |> Agala.Conn.send_to(bot_name) # You must explicitly specify bot name.
      |> Helpers.send_message(user_telegrma_id, message, []) # Helper function for telegram prpovider.
      |> IO.inspect
      |> Conn.with_fallback(&message_fallback(&1)) # Fallback after successful request sending. Pass Agala.Conn.t of finished request.
      # It is not necessary to pass fallback. It's just mechanism to make feedback after sending message.
      # For example it is necessary to display that message has been delivered. Or there could become error or something else.
    )
  end

  defp message_fallback(%Conn{fallback: %{"result" => %{"from" => %{"first_name" => first_name, "id" => id, "is_bot" => is_bot}, "text" => text}}} = _conn) do
    bot_postfix = if is_bot, do: "Bot", else: ""
    IO.puts("\n#{first_name} #{bot_postfix} #{id} : #{text}")
    IO.puts("----> You have just sent message <----")
  end

  defp message_fallback(%Conn{fallback: {:error, error}} = _conn) do
    IO.inspect error
    IO.puts("----> You have just get error HTTPoison <----")
  end

  defp message_fallback(%Conn{fallback: %{"description" => error}} = _conn) do
    IO.inspect error
    IO.puts("----> You have just get error response <----")
  end
end