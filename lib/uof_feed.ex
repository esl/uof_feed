defmodule UofFeed do
  @moduledoc false

  # This is a quick and dirty way of setting up default conn params
  # for convenient use from the shell.
  # It'll be dropped once we have proper config access.
  def connect(env \\ :integration, token \\ "0ur-t0k3n", bookmaker_id \\ 12345)

  def connect(env, token, bookmaker_id) do
    {uri, opts} = UofFeed.Config.amqp_opts(env, token, bookmaker_id)
    {:ok, conn} = AMQP.Connection.open(uri, opts)
    {:ok, chan} = AMQP.Channel.open(conn)

    # From https://iodocs.betradar.com/unifiedsdk/Betradar_Unified-Odds_Developer_Integration.pdf
    #
    #   Queue: You cannot create your own queues.
    #          Instead you have to request a server named queue (empty queue name in the request).
    #          Passive, Exclusive, Nondurable.
    #
    # I tried `passive` queue, but the call errored out. Only `passive: false` seems to work.
    # Since the queue names seem to be unique on each connection, I also added `auto_delete: true`,
    # though it's rather a broker issue to worry about dangling queues.
    queue_opts = [passive: false, exclusive: true, durable: false, auto_delete: true]
    {:ok, %{queue: queue}} = AMQP.Queue.declare(chan, "", queue_opts)
    IO.inspect(queue, label: :queue_name)

    exchange = "unifiedfeed"
    bind_opts = [routing_key: "#"]
    AMQP.Queue.bind(chan, queue, exchange, bind_opts)

    {:ok, chan, queue}
  end

  def recv(chan, queue) do
    {:ok, payload, meta} = AMQP.Basic.get(chan, queue)
  end

  # Just a demo for the shell, this might or might NOT work,
  # depending on whether there's a message waiting in the queue.
  # If there's no message, we'll get a badmatch on {:empty, %{cluster_id: ""}}
  def get_one_message do
    {:ok, chan, q} = connect()
    {:ok, xml, meta} = recv(chan, q)
    xml |> to_charlist |> :xmerl_scan.string() |> elem(0) |> :xmerl_lib.simplify_element()
  end
end
