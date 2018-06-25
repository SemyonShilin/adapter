defmodule Adapter.Telegram.Receiver do
#  @bevaviour Agala.Bot.Receiver
  use Agala.Bot.Receiver
  alias Agala.BotParams

  @certificate Application.get_env(:agala_telegram, :certificate)
  @url         Application.get_env(:agala_telegram, :url)

  defp set_webhook_url(%BotParams{provider_params: %{token: token}}) do
    "https://api.telegram.org/bot" <> token <> "/setWebhook"
  end

  defp server_webhook_url(%BotParams{provider_params: %{token: token}}) do
    @url <> token
  end

  defp create_body(map, opts) when is_map(map) do
    Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
  end

  defp create_body_multipart(map, opts) when is_map(map) do
    multipart =
      create_body(map, opts)
      |> Enum.map(fn
        {key, {:file, file}} -> {:file, file, {"form-data", [{:name, key}, {:filename, Path.basename(file)}]}, []}
        {key, value} -> {to_string(key), to_string(value)}
      end)
    {:multipart, multipart}
  end

  defp webhook_upload_body(bot_params, opts \\ []),
       do: create_body_multipart(%{certificate: {:file, @certificate}, url: server_webhook_url(bot_params)}, opts)

  defp server_webhook_options(%BotParams{private: %{http_opts: http_opts}}), do: http_opts

  def get_updates(notify_with, bot_params = %BotParams{}) do
    IO.inspect bot_params
    HTTPoison.post(
      set_webhook_url(bot_params),            # url
      webhook_upload_body(bot_params),        # body
      [{"Content-Type", "application/json"}], # headers
      server_webhook_options(bot_params)      # opts
    )
    |> IO.inspect
    |> parse_body()
    |> IO.inspect
    |> resolve_updates(notify_with, bot_params)
  end

  # Empty array of new messages
  defp resolve_updates(
         {
           :ok,
           %HTTPoison.Response{
             status_code: 200,
             body: %{"ok" => true, "result" => []}
           }
         },
         _,
         bot_params
       ), do: bot_params

  # This is just failed long polling, simply restart
  defp resolve_updates(
         {
           :error,
           %HTTPoison.Error{
             id: nil,
             reason: :timeout
           }
         },
         _,
         bot_params
       ) do
    Logger.debug("Webhook request ended with timeout, resend to poll")
    bot_params
  end

  # Good variant - acceptable results
  defp resolve_updates(
         {
           :ok,
           %HTTPoison.Response{
             status_code: 200,
             body: %{"ok" => true, "result" => result}
           }
         },
         notify_with,
         bot_params
       ) do
    Logger.debug fn -> "Response body is:\n #{inspect(result)}" end
    result
    |> process_messages(notify_with, bot_params)
  end

  # HTTP protocol error - resending LongPolling request
  defp resolve_updates({:ok, %HTTPoison.Response{status_code: status_code}}, _, bot_params) do
    Logger.warn("HTTP response ended with status code #{status_code}")
    bot_params
  end

  # HTTPoison error - resending LongPolling request
  defp resolve_updates({:error, err}, _, bot_params) do
    Logger.warn("#{inspect err}")
    bot_params
  end

  defp parse_body({:ok, resp = %HTTPoison.Response{body: body}}) do
    {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}
  end
  defp parse_body(default), do: default

  # Last message - updating offset with this message offset + 1
  defp process_messages([message] = [%{"update_id"=>offset}], notify_with, bot_params) do
    notify_with.(message)
    put_in(bot_params, [:private, :offset], offset + 1)
  end

  # Not last messages - simply passing to notify_with function
  defp process_messages([h|t], notify_with, bot_params) do
    notify_with.(h)
    process_messages(t, notify_with, bot_params)
  end

end