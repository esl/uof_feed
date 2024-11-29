defmodule UofFeed.Messages.Market do
  @moduledoc """
  DataSchema representation of a Market.

  ### Field list
    - `id` - the ID of the market,
    - `name` - the name of the market,
    - `specifiers` - the market specifiers,
    - `extended_specifers` - the market extended specifiers,
    - `void_reason` - reason for voiding particular market at it's outcomes,
    - `favourite` - recommended market, if present always set to 1,
    - `status` - the current status of the market.
    - `outcomes` - list of the `%Outcome{}` structs, describes possible market outcomes.

  ### Void reason field mapping
    - 0 - `OTHER`
    - 1 - `NO_GOALSCORER`
    - 2 - `CORRECT_SCORE_MISSING`
    - 3 - `RESULT_UNVERIFIABLE`
    - 4 - `FORMAT_CHANGE`
    - 5 - `CANCELLED_EVENT`
    - 6 - `MISSING_GOALSCORER`
    - 7 - `MATCH_ENDED_IN_WALKOVER`
    - 8 - `DEAD_HEAT`
    - 9 - `RETIRED_OR_DEFAULTED`
    - 10 - `EVENT_ABANDONED`
    - 11 - `EVENT_POSTPONED`
    - 12 - `INCORRECT_ODDS`
    - 13 - `INCORRECT_STATISTICS`
    - 14 - `NO_RESULT_ASSIGNABLE`
    - 15 - `CLIENT_SIDE_SETTLEMENT_NEEDED`
    - 16 - `STARTING_PITCHER_CHANGED`

  #### Market XML example from OddsChange message

  ```xml
  <market status="1" id="11">
    <outcome id="4" odds="2.09" active="1"/>
    <outcome id="5" odds="1.69" active="1"/>
  </market>
  ```

  #### Market XML example from BetCancel message
  ```xml
  <market name="1st half - 1st goal" id="62" specifiers="goalnr="1" void_reason="12"/>
  ```
  """
  use UofFeed.DataSchema

  alias UofFeed.Messages.Outcome

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          specifiers: String.t() | nil,
          extended_specifiers: String.t() | nil,
          void_reason: integer() | nil,
          favourite: integer() | nil,
          status: integer() | nil,
          outcomes: [Outcome.t()] | nil
        }

  data_schema(
    field: {:id, "./@id", &Utils.to_text/1, optional?: false},
    field: {:name, "./@name", &Utils.to_text/1, @options},
    field: {:specifiers, "./@specifiers", &Utils.to_text/1, @options},
    field: {:extended_specifiers, "./@extended_specifers", &Utils.to_text/1, @options},
    field: {:void_reason, "./@void_reason", &Utils.to_integer/1, @options},
    field: {:favourite, "./@favourite", &Utils.to_integer/1, @options},
    field: {:status, "./@status", &Utils.to_integer/1, @options},
    has_many: {:outcomes, "./outcome", Outcome, @options}
  )
end
