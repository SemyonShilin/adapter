defmodule Adapter.Schema.Messenger do
  use Ecto.Schema
  import Ecto.Changeset
  alias Adapter.Schema.Messenger

  schema "messengers" do
    field :name, :string
    has_many :bots, Adapter.Schema.Bot,
             foreign_key: :messenger_id,
             on_delete: :delete_all

    timestamps()
  end

  def changeset(messenger, params \\ %{}) do
    messenger
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def create(name \\ nil) do
    changeset = Messenger.changeset(%Messenger{}, %{name: name})
    new_messenger = Adapter.Repo.insert(changeset)
    case new_messenger do
      {:ok, messenger} -> messenger
      {:error, errors} -> errors.errors
    end
  end

  def add_bot(messenger, params \\ %{}) do
    bot = Ecto.build_assoc(messenger, :bots, params)
    Adapter.Schema.Bot.create(bot)
  end

  def find_by_name(name \\ nil) do
    Adapter.Repo.get_by(Messenger, name: name)
  end

  def delete(name) do
    messenger = Adapter.Repo.get_by(Messenger, name: name)
    Adapter.Repo.delete(messenger)
  end

  def pluck_bots_name_for(messenger) do
    Adapter.Schema.Messenger.find_by_name(messenger).id
    |> Adapter.Schema.Bot.where_messenger()
    |> Enum.map(fn(bot) -> Map.get(bot, :name) end)
  end
end
