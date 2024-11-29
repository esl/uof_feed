defmodule UofFeed.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: UofFeed.PubSub},
      {UofFeed.AMQP.Client, []}
    ]

    opts = [strategy: :one_for_one, name: UofFeed.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
