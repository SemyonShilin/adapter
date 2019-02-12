defmodule Adapter.Repo do
  use Ecto.Repo,
    otp_app: :adapter,
    adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    {:ok, opts}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
