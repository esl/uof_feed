# UofFeed

UofFeed is a library designed to connect to BetRadar AMQP queues. It provides
a simple mechanism for consuming and processing messages by defining a set of rules for
mapping messages from XML format to predefined Elixir structures.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `uof_feed` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uof_feed, "~> 0.1.0"}
  ]
end
```

## Configuration

After installing the dependency, copy the following configuration into your `config/config.ex`.
This contains default values that can be overridden, but necessary to correctly compile the library.

### Example

```elixir
config: :uof_feed,
    amqp_environment: :integration,
    amqp_handler: UofFeed.Handlers.XMLInspect,
    pubsub_topic: "uof-feed-messages",
    start_amqp_client?: true,
    amqp_token: "YOUR TOKEN",
    amqp_bookmaker_id: 1
```

- `amqp_environment` - used to determine API URL, default: `:integration`; for specifics check `UofFeed.AMQP.Config.amqp_opts/4`,
- `amqp_handler` - handler used to process the messages from XML, default: `UofFeed.Handlers.XMLInspect`; for more check [Message handlers](#message-handlers)
- `start_amqp_client?` - **IMPORTANT:** must be set to `true` to start `UofFeed.AMQP.Client` GenServer,
- `amqp_token`- your API token to access e.g. BetRadar API,
- `amqp_bookmaker_id` - the ID of bookmaker,
- `pubsub_topic` - `Phoenix.PubSub` topic to which processed messages should be broadcasted

## Quick start

To set up AMQP connection and start consuming the messages you can use `UofFeed.connect_and_subscribe/4` function.

It allows you to specify a simple message handler as function with arity of 2.

It's encouraged to use this function in `:dev` environment as means of verification or simple testing.
For production, it's recommended to use `UofFeed.AMQP.Client` and appropriate message [handler](#message-handlers).

### Examples

Required variables
```elixir
environment = :integration
token = "YOUR TOKEN"
port = 5671
```

#### Log incoming messages as XML:
```elixir
handler = fn xml, _meta -> IO.inspect(xml) end
UofFeed.connect_and_subscribe(:integration, token, port, handler)
```

#### Map and log the messages:
```elixir
handler = fn xml, _meta ->
    xml |> UofFeed.Mapper.call() |> IO.inspect()
end
UofFeed.connect_and_subscribe(:integration, token, port, handler)
```

## Currently implemented messages

`UofFeed` library implements mapping of the following XML messages from BetRadar:
- FixtureChange
- OddsChange
- BetStop
- BetCancel
- BetSettlement

**Notice**
There are some fields not fully mapped, e.g. `UofFeed.Messages.SportEventStatus`, expect such cases to gradually disappear.

## Message handlers

To accommodate different needs `UofFeed` library provides a set of default message handlers.
To configure message handler for `UOF.AMQP.Client` use `:uof_feed, :amqp_handler` in the [Configuration](#configuration)
- `UofFeed.Handlers.XMLInspect` - default message handler, logs raw XML into the logs,
- `UofFeed.Handlers.DataSchemaInspect` - map XML to Elixir structures, log the structures (or error) into the logs,
- `UofFeed.Handlers.PubSub` - map XML to Elixir structures and publish (using `Phoenix.PubSub`) results on specific topic (default: `uof-feed-messages`), check [Configuration](#configuration) on how to change it depending on your needs

### Custom message handlers

If none of the available [Message handlers](#message-handlers) meets your expectations you are free to implement your own.
To make it easier `UofFeed` library provides handler behaviour, `UofFeed.Handlers.Behaviour`

#### Examples

Custom handler
```elixir
defmodule Myapp.MyCustomHandler do
  use UofFeed.Handlers.Behaviour

  def handle_message(xml) do
    # your code here
    :ok
  end
end
```

In the config:
```elixir
config :uof_feed, amqp_handler: Myapp.MyCustomHandler
```

## Future improvements
  - Map all existing messages
  - Expand mapping to include all tags, e.g. add `statistics` and `period_scores` to `SportEventStatus` mapping
  - Add a Phoenix LiveView application to provide dashboard features
  - Improve application resiliency and error reporting
  - Add more message handlers
  - Expand list of providers
  - Add metrics
