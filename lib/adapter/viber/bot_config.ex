defmodule Adapter.Viber.BotConfig do
  @moduledoc """
    A module that collects the parameters of bots
  """

  alias Agala.Provider.Telegram.Conn.ProviderParams

  def get(name, token) do
    config(name, token)
  end

  defp config(name, token) do
    %Agala.BotParams{
      name: name,
      provider: Adapter.Viber.Provider,
      handler: Adapter.Viber.RequestHandler,
      provider_params: %ProviderParams{
        token: token,
        poll_timeout: :infinity
      }
    }
  end
end