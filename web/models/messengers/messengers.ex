defmodule Adapter.Messengers do
  @moduledoc """
  The Messengers context.
  """

  use Adapter.Web, :model

  alias Adapter.Messengers
  alias Adapter.Messengers.Messenger
  alias Adapter.Bots

  def list_messengers do
    Repo.all(Messenger)
  end

  def list_up_messengers do
    q = from m in Messenger, where: m.state == ~s"up"
    Repo.all(q)
  end

  def list_messengers_with_bots do
    Messenger
    |> Repo.all()
    |> Repo.preload(:bots)
  end

  def get_messenger!(id), do: Repo.get!(Messenger, id)

  def get_by_messenger(name), do: Repo.get_by(Messenger, name: name)

  def create_messenger(attrs \\ %{}) do
    %Messenger{}
    |> Messenger.changeset(attrs)
    |> Repo.insert()
  end

  def create(name \\ nil) do
    %Messenger{}
    |> Messenger.changeset(%{name: name, state: "up"})
    |> Repo.insert()
    |> case do
      {:ok, messenger} -> messenger
      {:error, changeset} -> changeset
    end
  end

  def update_messenger(%Messenger{} = messenger, attrs) do
    messenger
    |> Messenger.changeset(attrs)
    |> Repo.update()
  end

  def delete_messenger(%Messenger{} = messenger) do
    Repo.delete(messenger)
  end

  def change_messenger(%Messenger{} = messenger) do
    Messenger.changeset(messenger, %{})
  end

  def add_bot(messenger, params \\ %{}) do
    bot = Ecto.build_assoc(messenger, :bots, params)
    Bots.create(bot, params)
  end

  def find_by_name(name \\ nil), do: Repo.get_by(Messenger, name: name)

  def find_by_atts(%{} = attrs), do: Repo.get_by(Messenger, attrs)

  def delete(name) do
    messenger = Repo.get_by(Messenger, name: name)
    Repo.delete(messenger)
  end

  def pluck_bots_uid_for(messenger) do
    find_by_name(messenger).id
    |> Bots.where_messenger()
    |> Enum.map(fn(bot) -> Map.get(bot, :uid) end)
  end

  def set_down_messenger_tree(name) do
    case Messengers.get_by_messenger(name) do
      %Messenger{} = messenger ->
        Messengers.update_messenger(messenger, %{state: "down"})
        Bots.update_messenger_bots(messenger, [state: "down"])
      nil -> nil
    end
  end

  def set_up_messenger(name) do
    case Messengers.get_by_messenger(name) do
      %Messenger{} = mssg ->
        Messengers.update_messenger(mssg, %{state: "up"})
      nil -> nil
    end
  end
end
