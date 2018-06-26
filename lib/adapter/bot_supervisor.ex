defmodule Adapter.BotSupervisor do
  @moduledoc """
    Supervisor running for each bot and monitoring its components
  """

  use Supervisor, restart: :temporary

  @telegram_bot_method Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:method)

  def start_link(:ok, args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init({messenger, bot, token}) do
    children = spec(@telegram_bot_method, messenger, bot, token)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp spec(_method, messenger, bot, token) when messenger == "telegram",
       do: [
         {Adapter.Telegram, Adapter.Telegram.BotConfig.get(bot, token)},
         {Agala.Bot, Adapter.Telegram.BotConfig.get(bot, token)}
       ]

#  defp spec(:prod, messenger, bot, token) when messenger == "viber",
#       do: {}
end
