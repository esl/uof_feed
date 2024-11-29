defmodule UofFeed.Messages.Clock do
  @moduledoc """
  DataSchema representation of a Clock message (may contain unmapped fields).

  ### Field list
    - `match_time` - current match time, "47:50",
    - `remaining_time` - how much time until the end of the match, "40:10",
    - `stopped` - is the clock stopped? true/false
  """
  use UofFeed.DataSchema

  @type t :: %__MODULE__{
          match_time: String.t() | nil,
          remaining_time: String.t() | nil,
          stopped: boolean() | nil
        }

  data_schema(
    field: {:match_time, "./@match_time", &Utils.to_text/1, @options},
    field: {:remaining_time, "./@remaining_time", &Utils.to_text/1, @options},
    field: {:stopped, "./@stopped", &Utils.to_boolean/1, @options}
  )
end
