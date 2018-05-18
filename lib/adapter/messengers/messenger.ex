defmodule Adapter.Messengers.Messenger do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messengers" do
    field :name, :string
    field :state, :string

    has_many :bots, Adapter.Bots.Bot,
             foreign_key: :messenger_id,
             on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(messenger, params \\ %{}) do
    messenger
    |> cast(params, [:name, :state])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
