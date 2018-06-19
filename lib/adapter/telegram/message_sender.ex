defmodule Adapter.Telegram.MessageSender do
  @moduledoc """
  Module for sending messages to telegram
  """

  alias Agala.Provider.Telegram.Helpers
  alias Agala.Conn

  @bot_name Application.get_env(:adapter, :agala_telegram)[:name] # Bot name just like in bot configuration from paragraph #4

  def answer(telegram_user_id, message) do
    # Function for sending response to bot
    Agala.response_with(
      %Agala.Conn{} |> Agala.Conn.send_to(@bot_name) # You must explicitly specify bot name.
      |> Helpers.send_message(telegram_user_id, message, []) # Helper function for telegram prpovider.
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
end