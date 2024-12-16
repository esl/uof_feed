defmodule UofFeed.Handlers.DataSchemaInspect do
  @moduledoc """
  Process incoming messages from XML into Elixir structures and log the result

  Processing is done via `UofFeed.Mapper.call/1`.
  """
  @behaviour UofFeed.Handler

  require Logger

  alias UofFeed.Mapper

  def handle_message(message) do
    message
    |> Mapper.call()
    |> case do
      {:ok, mapped_message} ->
        Logger.info("#{inspect(mapped_message)}")

      error ->
        Logger.error("#{inspect(error)}")
    end

    :ok
  end
end
