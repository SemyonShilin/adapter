defmodule Adapter.Bots.Bot do
  use Adapter.Web, :model

  schema "bots" do
    field :uid, :string
    field :token, :string
    field :state, :string

    belongs_to :messenger, Adapter.Messengers.Messenger

    timestamps()
  end

  @doc false
  def changeset(bot, attrs) do
    bot
    |> cast(attrs, [:uid, :token, :state])
    |> validate_required([:uid, :token])
  end
end
