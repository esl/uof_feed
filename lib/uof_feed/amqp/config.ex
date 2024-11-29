defmodule UofFeed.AMQP.Config do
  @moduledoc """
  Functions to fetch AMQP configuration options and set up AMQP connection.
  """
  alias AMQP.Basic
  alias AMQP.Channel
  alias AMQP.Connection
  alias AMQP.Queue

  @environments [
    production: [amqp: "mq.betradar.com", api: "api.betradar.com"],
    integration: [amqp: "stgmq.betradar.com", api: "stgapi.betradar.com"],
    replay: [amqp: "replaymq.betradar.com", api: "stgapi.betradar.com"],
    global_production: [amqp: "global.mq.betradar.com", api: "global.api.betradar.com"],
    global_integration: [amqp: "global.stgmq.betradar.com", api: "global.stgapi.betradar.com"],
    proxy_singapore: [
      amqp: "mq.ap-southeast-1.betradar.com",
      api: "api.ap-southeast-1.betradar.com"
    ],
    proxy_tokyo: [amqp: "mq.ap-northeast-1.betradar.com", api: "api.ap-northeast-1.betradar.com"]
  ]

  @doc ~S"""
  Returns URI and connection options based on provided information.

  Available environemnts:
    - `:production`
    - `:integration` (default)
    - `:replay`
    - `:global_production`
    - `:global_integration`
    - `:proxy_singapore`
    - `:proxy_tokyo`

  Providing environemnt from outside of above list will result in response `{:error, :invalid_environment}`

  ## Examples

      iex> UofFeed.AMQP.Config.amqp_opts(:integration, "token", 12345)
      {:ok, {"amqps://token@stgmq.betradar.com", [port: 5671, virtual_host: "/unifiedfeed/12345"]}}

      iex> UofFeed.AMQP.Config.amqp_opts(:invalid, "token", 12345)
      {:error, :invalid_environment}
  """
  @spec amqp_opts(
          environemnt :: atom(),
          amqp_token :: String.t(),
          bookmaker_id :: integer(),
          integer()
        ) ::
          {:error, :invalid_environment} | {:ok, {uri :: String.t(), opts :: Keyword.t()}}
  def amqp_opts(env, token, bookmaker_id, port \\ 5671) do
    env
    |> environment_exists?()
    |> case do
      :ok ->
        scheme = "amqps"
        host = @environments[env][:amqp]

        {:ok,
         {
           "#{scheme}://#{token}@#{host}",
           [
             port: port,
             virtual_host: "/unifiedfeed/#{bookmaker_id}"
           ]
         }}

      error ->
        error
    end
  end

  @doc """
  Open AMQP connection and bind queue to it.
  """
  @spec setup_channel(uri :: String.t(), opts :: Keyword.t()) ::
          {:ok, Channel.t(), Basic.queue()} | Basic.error()
  def setup_channel(uri, opts) do
    with {:ok, conn} <- Connection.open(uri, opts),
         {:ok, channel} <- Channel.open(conn),
         {:ok, channel, queue} <- setup_queue(channel) do
      {:ok, channel, queue}
    else
      error -> error
    end
  end

  @doc """
  Decalre and bind AMQP queue to given channel.
  """
  @spec setup_queue(Channel.t()) :: {:ok, Channel.t(), AMQP.Basic.queue()} | AMQP.Basic.error()
  def setup_queue(channel) do
    queue_opts = [passive: false, exclusive: true, durable: false, auto_delete: true]
    exchange = "unifiedfeed"
    bind_opts = [routing_key: "#"]

    with {:ok, %{queue: queue}} <- Queue.declare(channel, "", queue_opts),
         :ok <- Queue.bind(channel, queue, exchange, bind_opts) do
      {:ok, channel, queue}
    else
      error -> error
    end
  end

  defp environment_exists?(env) when is_atom(env) do
    if env in Keyword.keys(@environments) do
      :ok
    else
      {:error, :invalid_environment}
    end
  end

  defp environment_exists?(_), do: {:error, :invalid_environment}
end
