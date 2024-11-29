import Config

config :uof_feed,
  amqp_environment: :integration,
  amqp_handler: UofFeed.Handlers.DataSchemaInspect,
  pubsub_topic: "uof-feed-messages",
  start_amqp_client?: false,
  amqp_token: "empty",
  amqp_bookmaker_id: 1

config :logger, truncate: :infinity

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:application, :version],
  truncate: :infinity

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [
    :application,
    :version
  ],
  truncate: :infinity

import_config "#{config_env()}.exs"
