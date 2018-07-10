defmodule Adapter.BotSupervisor do
  @moduledoc """
    Supervisor running for each bot and monitoring its components
  """

  use Supervisor, restart: :temporary

  def start_link(:ok, args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init({messenger, bot, token}) do
    children = spec(messenger, bot, token)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp spec(messenger, bot, token) when messenger == "telegram",
       do: [
         {Adapter.Telegram, Adapter.Telegram.BotConfig.get(bot, token)},
         {Agala.Bot, Adapter.Telegram.BotConfig.get(bot, token)}
       ]

  defp spec(messenger, bot, token) when messenger == "viber",
       do: [
         {Adapter.Viber, Adapter.Viber.BotConfig.get(bot, token)},
         {Agala.Bot, Adapter.Viber.BotConfig.get(bot, token)}
       ]
end
