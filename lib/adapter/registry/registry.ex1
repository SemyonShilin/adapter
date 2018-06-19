defmodule Adapter.Registry do
  @moduledoc """
    Модуль для реестра процессов
    Команды:
      1) Работа с реестром
         Adapter.Registry.create("telegram", {"bot_1", ""})
         Adapter.Registry.lookup("telegram")
         Adapter.Registry.down({:messenger, "telegram"})
         Adapter.Registry.down({:bot, "bot"})
      2) Работа с бд
         m = Adapter.Messengers.create("telegram")
         m = Adapter.Messengers.get_by_messenger("telegram")
         b = Adapter.Messengers.add_bot(m, %{uid: "bot", token: "TOKEN1"})
         Adapter.Repo.all(Adapter.Schema.Bot)
      3) Отправка сообщений пользователю
         Adapter.Registry.post_message("bot", "json")

  """

  use GenServer

  @name Adapter.Registry
  use Adapter.Registry.{Server, Client, Helpers}


  require Adapter.Registry.{Client, Server}

  def start_link(opts) do
    GenServer.start_link(@name, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {names, refs} = up_init_tree({%{}, %{}})
    {:ok, {names, refs}}
  end
end
