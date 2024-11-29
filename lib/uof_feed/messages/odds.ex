defmodule UofFeed.Messages.Odds do
  @moduledoc """
  DataSchema representation of an Odds message.

  Odds message is part of an OddsChange message.

  ### Field list
    - `betstop_reason` - the cause of bet stop,
    - `betting_status` - when set markets have been opened again after bet stop,
    - `markets` - list of `%Market{}` structures, describes markets
  """
  use UofFeed.DataSchema
  alias UofFeed.Messages.Market

  @type t :: %__MODULE__{
          betstop_reason: String.t() | nil,
          betting_status: integer() | nil,
          markets: [Market.t()]
        }

  data_schema(
    field: {:betstop_reason, "./@betstop_reason", &Utils.to_text/1, @options},
    field: {:betting_status, "./@betting_status", &Utils.to_integer/1, @options},
    has_many: {:markets, "./market", Market}
  )
end
