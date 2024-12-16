defmodule UofFeed.Messages.BetCancel do
  @moduledoc """
  DataSchema representation of a BetCancel message.

  ### Field list
    - `start_time`, `end_time` - timestamps for a time window during which bets should be canceled,
    - `event_id` - the ID of the event the `bet_cancel` refers to,
    - `product` - the producer that generated the message,
    - `timestamp` - when the `bet_cancel` event was generated
    - `superceded_by` - contains old `odds_change`, `bet_cancel` and new tournament season id,
      rarely used for outright odds if the original tournament season id was wrong,
    - `market` - `%Market{}` struct, describes which market for a bet should be cancelled.
  """
  use UofFeed.DataSchema

  alias UofFeed.Messages.Market

  @type t :: %__MODULE__{
          end_time: integer() | nil,
          event_id: String.t(),
          product: integer(),
          start_time: integer() | nil,
          timestamp: integer(),
          superceded_by: String.t() | nil,
          market: Market.t() | nil
        }

  data_schema(
    field: {:end_time, "./@end_time", &Utils.to_integer/1, @options},
    field: {:event_id, "./@event_id", &Utils.to_text/1, optional?: false},
    field: {:product, "./@product", &Utils.to_integer/1, optional?: false},
    field: {:start_time, "./@start_time", &Utils.to_integer/1, @options},
    field: {:timestamp, "./@timestamp", &Utils.to_integer/1, optional?: false},
    field: {:superceded_by, "./@superceded_by", &Utils.to_text/1, @options},
    has_one: {:market, "./market", Market, @options}
  )

  @doc ~S"""
  Create new `%BetCancel{}` struct based on provided XML.

  ## Examples

      iex> input = '''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <bet_cancel end_time="1564598513000" event_id="sr:match:18941600" product="1"
      ...>    start_time="1564597838000" timestamp="1564602448841">
      ...> <market name="1st half - 1st goal" id="62" specifiers="goalnr=1" void_reason="12"/>
      ...> </bet_cancel>
      ...> '''
      iex> UofFeed.Messages.BetCancel.new(input)
      {:ok, %UofFeed.Messages.BetCancel{
        end_time: 1564598513000,
        event_id: "sr:match:18941600",
        product: 1,
        start_time: 1564597838000,
        timestamp: 1564602448841,
        superceded_by: nil,
        market: %UofFeed.Messages.Market{
          name: "1st half - 1st goal",
          id: "62",
          specifiers: "goalnr=1",
          void_reason: 12,
          favourite: nil,
          outcomes:  nil,
          status: nil,
          extended_specifiers: nil,
        }
      }}

  Errors encountered during data processing will be reported.

      iex> input = '''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <bet_cancel end_time="1564598513000" event_id="sr:match:18941600" product="1"
      ...>    start_time="invalid" timestamp="1564602448841">
      ...> <market name="1st half - 1st goal" id="62" specifiers="goalnr=1" void_reason="12"/>
      ...> </bet_cancel>
      ...> '''
      iex> UofFeed.Messages.BetCancel.new(input)
      {:error, {[:start_time], "Invalid data provided, expected integer as string, received: invalid"}}
  """
  @spec new(xml :: String.t()) ::
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
