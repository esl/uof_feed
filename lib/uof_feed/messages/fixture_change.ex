defmodule UofFeed.Messages.FixtureChange do
  @moduledoc """
  DataSchema representation of a FixtureChange message.

  ### Field list:
    - `start_time` - start time of the event,
    - `product` - the ID of the producer that generated the message,
    - `event_id` - the ID of the sport event,
    - `timestamp` - the time the message was generated,
    - `change_type` - fixture change type

  ### Change type field mapping:
    - 1 - `NEW`
    - 2 - `DATE_TIME`
    - 3 - `CANCELLED`
    - 4 - `FORMAT`
    - 5 - `COVERAGE`
    - 6 - `PITCHER`
  """
  use UofFeed.DataSchema

  @type t :: %__MODULE__{
          start_time: integer(),
          product: integer(),
          event_id: String.t(),
          timestamp: integer(),
          change_type: integer() | nil
        }

  data_schema(
    field: {:start_time, "./@start_time", &Utils.to_integer/1},
    field: {:product, "./@product", &Utils.to_integer/1},
    field: {:event_id, "./@event_id", &{:ok, &1}},
    field: {:timestamp, "./@timestamp", &Utils.to_integer/1},
    field: {:change_type, "./@change_type", &Utils.to_integer/1, @options}
  )

  @doc ~S"""
  Create new `%FixtureChange{}` struct based on provided XML.

  ## Examples

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <fixture_change start_time="1730223000000" product="1" event_id="sr:match:52371543"
      ...>    timestamp="1729840401716" change_type="1" />
      ...> '''
      iex> UofFeed.Messages.FixtureChange.new(input)
      {:ok,
        %UofFeed.Messages.FixtureChange{
          change_type: 1,
          start_time: 1730223000000,
          product: 1,
          event_id: "sr:match:52371543",
          timestamp: 1729840401716
        }
      }

  Optional fields like `change_type` don't have to be present in the input structure:

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <fixture_change start_time="1730223000000" product="1"
      ...>    event_id="sr:match:52371543" timestamp="1729840401716"/>"
      ...> '''
      iex> UofFeed.Messages.FixtureChange.new(input)
      {:ok,
        %UofFeed.Messages.FixtureChange{
          change_type: nil,
          start_time: 1730223000000,
          product: 1,
          event_id: "sr:match:52371543",
          timestamp: 1729840401716
        }
      }

  Errors encoutered during data processing will be reported.
  NOTE: Only the first error is reported.

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <fixture_change start_time="invalid" product="1"
      ...>    event_id="sr:match:52371543" timestamp="1729840401716"/>
      ...> '''
      iex> UofFeed.Messages.FixtureChange.new(input)
      {:error, {[:start_time], "Invalid data provided, expected integer as string, received: invalid"}}
  """
  @spec new(xml :: charlist()) ::
          {:ok, __MODULE__.t()} | {:error, {access_path :: list(atom()), message :: String.t()}}
  def new(xml) do
    xml
    |> DataSchema.to_struct(__MODULE__)
    |> case do
      {:ok, _} = result -> result
      {:error, ds_errors} -> to_error_tuple(ds_errors)
    end
  end
end
