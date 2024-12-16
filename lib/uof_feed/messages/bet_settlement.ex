defmodule UofFeed.Messages.BetSettlement do
  @moduledoc """
  DataSchema representation of a BetSettlement message.

  ### Field list
    - `certainty` - is this message based on live result reports (1) or official result confirmation (2),
    - `product` - the producer that generated the message,
    - `event_id` - the ID of the event the `bet_settlement` refres to,
    - `timestamp` - when `bet_settlement` event was generated,
    - `outcomes` - list of `%Market{}` containing bet outcomes
  """
  use UofFeed.DataSchema

  alias UofFeed.Messages.Market

  @type t :: %__MODULE__{
          certainty: integer(),
          product: integer(),
          event_id: String.t(),
          timestamp: integer(),
          outcomes: [Market.t()]
        }

  data_schema(
    field: {:certainty, "./@certainty", &Utils.to_integer/1, optional?: false},
    field: {:product, "./@product", &Utils.to_integer/1, optional?: false},
    field: {:event_id, "./@event_id", &Utils.to_text/1, optional?: false},
    field: {:timestamp, "./@timestamp", &Utils.to_integer/1, optional?: false},
    has_many: {:outcomes, "./outcomes/market", Market, @options}
  )

  @doc ~S"""
  Create new `%BetSettlement{}` struct based on provided XML.

  ## Examples

      iex> input = '''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <bet_settlement certainty="2" product="3" event_id="sr:match:16807109" timestamp="1547538073717">
      ...>  <outcomes>
      ...>    <market id="193">
      ...>      <outcome id="74" result="0"/>
      ...>      <outcome id="76" result="1"/>
      ...>    </market>
      ...>  </outcomes>
      ...> </bet_settlement>
      ...> '''
      iex> UofFeed.Messages.BetSettlement.new(input)
      {:ok, %UofFeed.Messages.BetSettlement{
        certainty: 2,
        product: 3,
        event_id: "sr:match:16807109",
        timestamp: 1547538073717,
        outcomes: [
          %UofFeed.Messages.Market{
            id: "193",
            name: nil,
            specifiers: nil,
            extended_specifiers: nil,
            void_reason: nil,
            favourite: nil,
            status: nil,
            outcomes: [
              %UofFeed.Messages.Outcome{
                id: "74",
                result: 0,
                odds: nil,
                active: nil,
                void_factor: nil,
                dead_heat_factor: nil
              },
              %UofFeed.Messages.Outcome{
                id: "76",
                result: 1,
                odds: nil,
                active: nil,
                void_factor: nil,
                dead_heat_factor: nil
              }
            ]
          }
        ]
      }}


  Errors encountered during data processing will be reported.

      iex> input = '''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <bet_settlement certainty="invalid" product="3" event_id="sr:match:16807109" timestamp="1547538073717">
      ...>  <outcomes>
      ...>    <market id="193">
      ...>      <outcome id="74" result="0"/>
      ...>      <outcome id="76" result="1"/>
      ...>    </market>
      ...>  </outcomes>
      ...> </bet_settlement>
      ...> '''
      iex> UofFeed.Messages.BetSettlement.new(input)
      {:error, {[:certainty], "Invalid data provided, expected integer as string, received: invalid"}}
  """
  @spec new(xml :: String.t()) ::
          {:ok, __MODULE__.t()} | {:error, access_path :: list(atom()), message :: String.t()}
  def new(xml) do
    xml
    |> DataSchema.to_struct(__MODULE__)
    |> case do
      {:ok, _} = result -> result
      {:error, ds_errors} -> to_error_tuple(ds_errors)
    end
  end
end
