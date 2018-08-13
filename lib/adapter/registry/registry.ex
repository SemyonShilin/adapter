defmodule Adapter.Registry do
  @moduledoc """
    Модуль для реестра процессов
    Команды:
      1) Работа с реестром
         Adapter.Registry.create("telegram", {"bot_1", "TOKEN"})
         Adapter.Registry.lookup("telegram")
         Adapter.Registry.down({:messenger, "telegram"})
         Adapter.Registry.down({:bot,A "bot"})
      2) Работа с бд
         m = Adapter.Messengers.create("telegram")
         m = Adapter.Messengers.get_by_messenger("telegram")
         b = Adapter.Messengers.add_bot(m, %{uid: "bot", token: "TOKEN", state: "up"})
         Adapter.Repo.all(Adapter.Schema.Bot)
         Adapter.Messengers.Messenger |> Adapter.Repo.delete_all
         Adapter.Bots.Bot |> Adapter.Repo.delete_all
      3) Отправка сообщений пользователю
         Adapter.Registry.post_message("bot", "json")
  """

  use GenServer
  use Adapter.Registry.{Server, Client, Helpers}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {names, refs} = up_init_tree({%{}, %{}})
    {:ok, {names, refs}}
  end
end
