defmodule UofFeed.Handlers.XMLInspect do
  @moduledoc """
  Default message handler, prints RAW XML into the logs.
  """
  @behaviour UofFeed.Handler

  require Logger

  def handle_message(message) do
    Logger.info(message)
    :ok
  end
end
