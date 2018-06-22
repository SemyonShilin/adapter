defmodule Adapter.Telegram.BotConfig do
  alias Agala.Provider.Telegram.Conn.ProviderParams

  @bot_method Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:method)
  @proxy      Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:proxy)
  @user      Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:user)
  @password      Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:password)

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
    config(@bot_method, name, token)
  end

  defp config(:polling, name, token) do
    %Agala.BotParams{
      name: name, # You can use any string. It's using for sending message from specific bot in paragraph #6
      provider: Agala.Provider.Telegram,
      handler: Adapter.Telegram.RequestHandler, # RequestHandler from paragraph #2
      provider_params: %ProviderParams{
        token: token, # Token from paragraph #3
        poll_timeout: :infinity,
        hackney_opts: parse_proxy(@proxy)
      },
      private: %{
        http_opts: parse_proxy(@proxy)
      }
    }
  end

  defp config(:webhook, name, token) do
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

  defp parse_proxy({:http, config}) do
    [proxy: config]
  end

  defp parse_proxy({:https, config}) do
    [proxy: config]
  end

  defp parse_proxy({:socks5, config}) do
    [proxy: config]
  end
end