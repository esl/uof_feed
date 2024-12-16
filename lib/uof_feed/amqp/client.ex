defmodule UofFeed.AMQP.Client do
  @moduledoc """
  GenServer implementing AMQP message consumer.
  """
  use GenServer
  use AMQP

  @token Application.compile_env!(:uof_feed, :amqp_token)
  @bookmaker_id Application.compile_env!(:uof_feed, :amqp_bookmaker_id)
  @environment Application.compile_env!(:uof_feed, :amqp_environment)
  @start_client? Application.compile_env!(:uof_feed, :start_amqp_client?)

  alias UofFeed.AMQP.Config

  require Logger

  def start_link(_) do
    if @start_client? do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    else
      :ignore
    end
  end

  def init(_opts) do
    if config_valid?(@token, @bookmaker_id) do
      {:ok, {uri, opts}} = Config.amqp_opts(@environment, @token, @bookmaker_id)
      {:ok, channel, queue} = Config.setup_channel(uri, opts)
      {:ok, _consumer_tag} = Basic.consume(channel, queue)

      {:ok, channel}
    else
      {:stop, :missing_config}
    end
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, _data}, channel) do
    Logger.info("The process has been successfully registered as a consumer.")
    {:noreply, channel}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, _data}, channel) do
    {:stop, :normal, channel}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, _data}, channel) do
    {:noreply, channel}
  end

  def handle_info({:basic_deliver, payload, _data}, channel) do
    UofFeed.handle_message(payload)
    {:noreply, channel}
  end

  def config_valid?("empty", 1), do: false
  def config_valid?(_, _), do: true
end
