defmodule Adapter.Schema.Messenger do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messengers" do
    field :name, :string
    has_many :bots, Adapter.Schema.Bot, foreign_key: :messenger_id

    timestamps()
  end

  def changeset(messenger, params \\ %{}) do
    messenger
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
