defmodule UofFeed.Messages.SportEventStatus do
  @moduledoc """
  DataSchema representation of a SportEventStatus message.

  SportEventStatus message is part of an OddsChange message.

  ### Field list
    - `status` - status of the sport event,
    - `match_status` - status of the match,
    - `reporting` - information if reporting is turned on,
    - `home_score` - socre of the home team,
    - `away_score` - score of the away(guest) team,
    - `clock` - `%Clock{}` struct, describes current time for the event (e.g. soccer match current clock status)

  #### NOTE
  This field also contains information about match statistics and period scores, currently unmapped.
  """
  use UofFeed.DataSchema

  alias UofFeed.Messages.Clock

  @type t :: %__MODULE__{
          status: integer() | nil,
          match_status: integer() | nil,
          reporting: integer() | nil,
          home_score: integer() | nil,
          away_score: integer() | nil,
          clock: Clock.t() | nil
        }

  data_schema(
    field: {:status, "./@status", &Utils.to_integer/1, @options},
    field: {:match_status, "./@match_status", &Utils.to_integer/1, @options},
    field: {:reporting, "./@reporting", &Utils.to_integer/1, @options},
    field: {:home_score, "./@home_score", &Utils.to_integer/1, @options},
    field: {:away_score, "./@away_score", &Utils.to_integer/1, @options},
    has_one: {:clock, "./clock", Clock, @options}
  )
end
