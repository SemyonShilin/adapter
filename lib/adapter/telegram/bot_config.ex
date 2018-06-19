defmodule Adapter.Telegram.BotConfig do
  alias Agala.Provider.Telegram.Conn.ProviderParams


  def get do
    %Agala.BotParams{
      name: Application.get_env(:sandbox, :agala_telegram)[:name], # You can use any string. It's using for sending message from specific bot in paragraph #6
      provider: Agala.Provider.Telegram,
      handler: Adapter.Telegram.RequestHandler, # RequestHandler from paragraph #2
      provider_params: %ProviderParams{
        token: Application.get_env(:adapter, :agala_telegram)[:token], # Token from paragraph #3
        poll_timeout: :infinity
      }
    }
  end

  def get(name, token) do
    config(Mix.env, name, token)
  end

  defp config(:dev, name, token) do
    %Agala.BotParams{
      name: name, # You can use any string. It's using for sending message from specific bot in paragraph #6
      provider: Agala.Provider.Telegram,
      handler: Adapter.Telegram.RequestHandler, # RequestHandler from paragraph #2
      provider_params: %ProviderParams{
        token: token, # Token from paragraph #3
        poll_timeout: :infinity
      }
    }
  end

  defp config(:prod, name, token) do
    %Agala.BotParams{
      name: name, # You can use any string. It's using for sending message from specific bot in paragraph #6
      provider: Adapter.Telegram,
      handler: Adapter.WebhookController, # RequestHandler from paragraph #2
      provider_params: %ProviderParams{
        token: token, # Token from paragraph #3
        poll_timeout: :infinity
      }
    }
  end
end