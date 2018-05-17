defmodule Adapter.Bots.Bot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bots" do
    field :uid, :string
    field :token, :string

    belongs_to :messenger, Adapter.Messengers.Messenger

    timestamps()
  end

  @doc false
  def changeset(bot, attrs) do
    bot
    |> cast(attrs, [:uid, :token])
    |> validate_required([:uid, :token])
  end
end
