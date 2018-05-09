defmodule Adapter.Schema.Bot do
  use Ecto.Schema
  import Ecto.Changeset
  alias Adapter.Schema.Bot
  import Ecto.Query

  schema "bots" do
    field :name, :string
    field :token, :string
    belongs_to :messenger, Adapter.Schema.Messenger

    timestamps()
  end

  def changeset(messenger, params \\ %{}) do
    messenger
    |> cast(params, [:name, :token])
    |> validate_required([:name, :token])
  end

  def create(bot) do
    new_messenger = Adapter.Repo.insert(bot)
    case new_messenger do
      {:ok, messenger} -> messenger
      {:error, errors} -> errors.errors
    end
  end

  def create(name \\ nil, token \\ nil) do
    changeset = Bot.changeset(%Bot{}, %{name: name, token: token})
    new_bot = Adapter.Repo.insert(changeset)
    case new_bot do
      {:ok, bot} -> bot
      {:error, errors} -> errors.errors
    end
  end

  def where_messenger(id) do
    q = from b in Bot, where: b.messenger_id == ^id
    Adapter.Repo.all(q) |> Adapter.Repo.preload(:messenger)
  end
end
