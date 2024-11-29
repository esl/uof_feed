defmodule UofFeed.Messages.BetStop do
  @moduledoc """
  DataSchema representation of a BetStop message.

  ### Field list
    - `timestamp` - when the `bet_stop` event was generated,
    - `product` - the producer that generated the message,
    - `event_id` - the ID of the event the `bet_stop` refres to,
    - `groups` - describes which  set of markets should be suspended

  ### Unmapped fields
    - betstop_reason
    - market_status
  """
  use UofFeed.DataSchema

  @type t :: %__MODULE__{
          timestamp: integer(),
          product: integer(),
          event_id: String.t(),
          groups: String.t() | nil
        }

  data_schema(
    field: {:timestamp, "./@timestamp", &Utils.to_integer/1, optional?: false},
    field: {:product, "./@product", &Utils.to_integer/1, optional?: false},
    field: {:event_id, "./@event_id", &Utils.to_text/1, optional?: false},
    field: {:groups, "./@groups", &Utils.to_text/1, @options}
  )

  @doc ~S"""
  Create new `%BetStop{}` struct based on provided XML.

  ## Examples

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <bet_stop timestamp="12345" product="3" event_id="sr:match:471123" groups="all"/>
      ...> '''
      iex> UofFeed.Messages.BetStop.new(input)
      {:ok, %UofFeed.Messages.BetStop{
        timestamp: 12345,
        product: 3,
        event_id: "sr:match:471123",
        groups: "all"
      }}

  Errors encountered during data processing will be reported.

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <bet_stop timestamp="12345" product="invalid" event_id="sr:match:471123" groups="all"/>
      ...> '''
      iex> UofFeed.Messages.BetStop.new(input)
      {:error, {[:product], "Invalid data provided, expected integer as string, received: invalid"}}
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
