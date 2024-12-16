defmodule UofFeed.Messages.Outcome do
  @moduledoc """
  DataSchema representation of an Outcome.

  Outcome message is part of a Market mesage.

  ### Field list
    - `id` - the ID of an outcome,
    - `odds` - the odds for specific outcome ID,
    - `active` - is outcome active? `1` - yes, `0` - no,
    - `result` - result of the outcome, `0` - lost, `1` - won, `-1` - undecided_yet
    - `void_factor` - amount of placed bet that should be returned for an outcome, `0.5` if half, `1.0` if full amount
    - `dead_heat_factor` - team/player place is shared with multiple others this reducing payout.
  """
  use UofFeed.DataSchema

  @type t :: %__MODULE__{
          id: String.t(),
          odds: Decimal.t() | nil,
          active: boolean() | nil,
          result: integer() | nil,
          void_factor: Decimal.t() | nil,
          dead_heat_factor: String.t() | nil
        }

  data_schema(
    field: {:id, "./@id", &Utils.to_text/1, optional?: false},
    field: {:odds, "./@odds", &Utils.to_decimal/1, @options},
    field: {:active, "./@active", &Utils.to_integer/1, @options},
    field: {:result, "./@result", &Utils.to_integer/1, @options},
    field: {:void_factor, "./@void_factor", &Utils.to_decimal/1, @options},
    field: {:dead_heat_factor, "./@dead_heat_factor", &Utils.to_text/1, @options}
  )
end
