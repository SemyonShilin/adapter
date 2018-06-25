defmodule Adapter.Telegram.Receiver do
  @moduledoc """
  Main worker module
  """
  use Agala.Bot.Receiver
  alias Agala.BotParams

  def get_updates(notify_with, bot_params = %BotParams{}) do
    bot_params
  end
end
