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
       do: Engine.Telegram.Spec.engine_spec(bot, token)

  defp spec(messenger, bot, token) when messenger == "viber",
       do: Engine.Viber.Spec.engine_spec(bot, token)
end
