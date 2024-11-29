defmodule UofFeed.Messages.OddsChange do
  @moduledoc """
  DataSchema representation of an OddsChange message.

  ### Field list
    - `event_id` - the ID of the event `odds_change` refers to,
    - `timestamp` - when the odds for this message were generated,
    - `product` - the producer that generated the message,
    - `odds` - `%Odds{}` struct, describes list of markets,
    - `sport_event_status` - `%SportEventStatus{}` struct, describes additional information about the sport event, like statistics, period scores or clock.
  """
  use UofFeed.DataSchema

  alias UofFeed.Messages.Odds
  alias UofFeed.Messages.SportEventStatus

  @type t :: %__MODULE__{
          event_id: String.t(),
          timestamp: integer(),
          product: integer(),
          sport_event_status: SportEventStatus.t() | nil,
          odds: Odds.t() | nil
        }

  data_schema(
    field: {:event_id, "./@event_id", &Utils.to_text/1, optional?: false},
    field: {:timestamp, "./@timestamp", &Utils.to_integer/1, optional?: false},
    field: {:product, "./@product", &Utils.to_integer/1, optional?: false},
    has_one: {:sport_event_status, "./sport_event_status", SportEventStatus, @options},
    has_one: {:odds, "./odds", Odds, @options}
  )

  @doc ~S"""
  Create new `%OddsChange{}` struct based on provided XML.

  ## Examples

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <odds_change event_id="sr:match:1234" timestamp="1234" product="2">
      ...> <sport_event_status status="1" reporting="1" match_status="1" home_score="2" away_score="0">
      ...> <clock match_time="10:00" remaining_time="50:00" stopped="true"/>
      ...> </sport_event_status>
      ...> <odds>
      ...> <market id="47" specifiers="score=41.5" favourite="1" status="1">
      ...>  <outcome id="1" odds="1.12" active="1"/>
      ...>  <outcome id="2" odds="1.92" active="1"/>
      ...> </market>
      ...> </odds>
      ...> </odds_change>
      ...> '''
      iex> UofFeed.Messages.OddsChange.new(input)
      {:ok, %UofFeed.Messages.OddsChange{
        event_id: "sr:match:1234",
        timestamp: 1234,
        product: 2,
        sport_event_status: %UofFeed.Messages.SportEventStatus{
          status: 1,
          match_status: 1,
          reporting:  1,
          home_score: 2,
          away_score: 0,
          clock: %UofFeed.Messages.Clock{
            match_time: "10:00",
            remaining_time: "50:00",
            stopped: nil
          },
        },
        odds: %UofFeed.Messages.Odds{
          betstop_reason: nil,
          betting_status: nil,
          markets: [
            %UofFeed.Messages.Market{
              id: "47",
              name: nil,
              specifiers: "score=41.5",
              void_reason: nil,
              favourite: 1,
              status: 1,
              outcomes: [
                %UofFeed.Messages.Outcome{
                  id: "1",
                  odds: Decimal.new("1.12"),
                  active: 1,
                },
                %UofFeed.Messages.Outcome{
                  id: "2",
                  odds: Decimal.new("1.92"),
                  active: 1,
                }
              ]
            }
          ]
        }
      }}
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
