defmodule UofFeed do
  @moduledoc """
  Delegate XML handling to appropiate handler.
  Convenience functions for working with AMQP connections.
  """
  alias UofFeed.AMQP.Config

  @handler Application.compile_env!(:uof_feed, :amqp_handler)

  defdelegate handle_message(msg), to: @handler

  @doc """
  Convenience function to set up AMQP connection and consume messages
  using `handler/2` function.

  The `handler/2` function must have an arity of 2, the first parameter will always
  be a binary with the XML message and the second will be a Map with the message properties.

  ## Example

  iex> UofFeed.connect_and_subscribe(:integration, "token", 12345, fn xml, _meta -> IO.inspect(xml) end)

  """
  @spec connect_and_subscribe(
          environemnt :: atom(),
          amqp_token :: String.t(),
          bookmaker_id :: integer(),
          handler :: function()
        ) :: {:ok, String.t()} | {:error, :invalid_environment} | AMQP.Basic.error()
  def connect_and_subscribe(env, token, bookmaker_id, handler) do
    with {:ok, {uri, opts}} <- Config.amqp_opts(env, token, bookmaker_id),
         {:ok, channel, queue} <- Config.setup_channel(uri, opts),
         {:ok, _} <- AMQP.Queue.subscribe(channel, queue, handler) do
    else
      error -> error
    end
  end
end
