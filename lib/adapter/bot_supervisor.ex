defmodule Adapter.BotSupervisor do
  use Supervisor, restart: :temporary

  @bot_method Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:method)

  def start_link(:ok, args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init({messenger, bot, token}) do
    children = spec(@bot_method, messenger, bot, token)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp spec(:polling, messenger, bot, token) when messenger == "telegram",
       do: [{Agala.Bot, Adapter.Telegram.BotConfig.get(bot, token)}]

  defp spec(:webhook, messenger, bot, token) when messenger == "telegram",
       do: [
         {Adapter.Telegram, Adapter.Telegram.BotConfig.get(bot, token)},
         {Agala.Bot.Handler, Adapter.Telegram.BotConfig.get(bot, token)},
#         {Agala.Provider.Telegram.Responser, Adapter.Telegram.BotConfig.get(bot, token)},
         {Agala.Bot.Storage.Local, Adapter.Telegram.BotConfig.get(bot, token)}
       ]

#  defp spec(:prod, messenger, bot, token) when messenger == "viber",
#       do: {}
end
