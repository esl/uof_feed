defmodule UofFeed.Handlers.PubSub do
  @moduledoc """
  Process incoming messages from XML into Elixir structs and publish on Phoenix.PubSub topic.

  Processing is done via `UofFeed.Mapper.call/1`.
  """
  @behaviour UofFeed.Handler
  @topic Application.compile_env!(:uof_feed, :pubsub_topic)

  alias Phoenix.PubSub
  alias UofFeed.Mapper

  require Logger

  def handle_message(raw_xml) do
    raw_xml
    |> Mapper.call()
    |> case do
      {:ok, data} -> PubSub.broadcast(UofFeed.PubSub, @topic, data)
      {:error, error} -> Logger.error("Parsing error: #{inspect(error)}")
    end

    :ok
  end
end
