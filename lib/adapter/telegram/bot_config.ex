defmodule Adapter.Telegram.BotConfig do
  @moduledoc """
    A module that collects the parameters of bots
  """

  alias Agala.Provider.Telegram.Conn.ProviderParams

  @bot_method Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:method)
  @proxy      Application.get_env(:adapter, Adapter.Telegram) |> Keyword.get(:proxy)

  def get do
    %Agala.BotParams{
      name: Application.get_env(:sandbox, :agala_telegram)[:name],
      provider: Agala.Provider.Telegram,
      handler: Adapter.Telegram.RequestHandler,
      provider_params: %ProviderParams{
        token: Application.get_env(:adapter, :agala_telegram)[:token],
        poll_timeout: :infinity
      }
    }
  end

  def get(name, token) do
    config(@bot_method, name, token)
  end

  defp config(:polling, name, token) do
    %Agala.BotParams{
      name: name,
      provider: Agala.Provider.Telegram,
      handler: Adapter.Telegram.RequestHandler,
      provider_params: %ProviderParams{
        token: token,
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
      name: name,
      provider: Adapter.Telegram.Provider,
      handler: Adapter.Telegram.RequestHandler,
      provider_params: %ProviderParams{
        token: token,
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
end