defmodule Adapter.Viber.Receiver do
  @moduledoc """
  Main worker module
  """
  use Agala.Bot.Receiver

  def get_updates(_notify_with, %Agala.BotParams{} = bot_params) do
    bot_params
  end
end
