#defmodule Adapter.BotSupervisor do
#  @moduledoc """
#  {Agala.Bot,
#   %Agala.BotParams{
#     common: %{},
#     handler: Adapter.Telegram.RequestHandler,
#     name: nil,
#     private: %{},
#     provider: Agala.Provider.Telegram,
#     provider_params: %Agala.Provider.Telegram.Conn.ProviderParams{
#       hackney_opts: [],
#       poll_timeout: :infinity,
#       response_timeout: nil,
#       token: "390126265:AAGokHwWau7N7sd9Vga0g_qE3-Th9gNcXME"
#     },
#     storage: Agala.Bot.Storage.Local
#   }}
#  """
#
#  use DynamicSupervisor, restart: :temporary
#
#  def start_link(:ok, _opts) do
#    DynamicSupervisor.start_link(__MODULE__, :ok)
#  end
#
#  def start_new_instance(pid, {messenger, bot, token}) do
#    spec = spec(Mix.env, messenger, bot, token)
#    IO.inspect spec
#    IO.inspect DynamicSupervisor.start_child(pid, spec)
#  end

#
#
#  def init(initial_arg) do
#    DynamicSupervisor.init(
#      strategy: :one_for_one,
#      extra_arguments: [initial_arg]
#    )
#  end
#
#  defp spec(:dev, messenger, bot, token) when messenger == "telegram",
#       do: {Agala.Bot, Adapter.Telegram.BotConfig.get(bot, token)}
#
#  defp spec(:prod, messenger, {bot, token}) when messenger == "telegram",
#       do: {Adapter.Telegram, Adapter.Telegram.BotConfig.get(bot, token)}
#
#  defp spec(:prod, messenger, {bot, token}) when messenger == "viber",
#       do: {}
#end

defmodule Adapter.BotSupervisor do
  use Supervisor, restart: :temporary

  def start_link(:ok, args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init({messenger, bot, token}) do
    children = [
      spec(Application.get_env(:agala_telegram, :method), messenger, bot, token)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp spec(:polling, messenger, bot, token) when messenger == "telegram",
       do: {Agala.Bot, Adapter.Telegram.BotConfig.get(bot, token)}

  defp spec(:webhook, messenger, bot, token) when messenger == "telegram",
       do: {Adapter.Telegram, Adapter.Telegram.BotConfig.get(bot, token)}

#  defp spec(:prod, messenger, bot, token) when messenger == "viber",
#       do: {}
end
