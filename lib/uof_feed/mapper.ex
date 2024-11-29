defmodule UofFeed.Mapper do
  @moduledoc """
  Process messages from XML into Elixir structs.

  Use:
    - SweetXml - extract data from provided XML using xpath
    - DataSchema - parse and validate decoded message into Elixir struct
  """
  import SweetXml, only: [sigil_x: 2]

  alias UofFeed.Messages.Alive
  alias UofFeed.Messages.BetCancel
  alias UofFeed.Messages.BetSettlement
  alias UofFeed.Messages.BetStop
  alias UofFeed.Messages.FixtureChange
  alias UofFeed.Messages.OddsChange

  @doc ~S"""
  Run mapping function.

  ## Examples

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <fixture_change start_time="1730223000000" product="1"
      ...>    event_id="sr:match:52371543" timestamp="1729840401716"/>"
      ...> '''
      iex> UofFeed.Mapper.call(input)
      {:ok,
        %UofFeed.Messages.FixtureChange{
          change_type: nil,
          start_time: 1730223000000,
          product: 1,
          event_id: "sr:match:52371543",
          timestamp: 1729840401716
        }
      }

  Unsupported messages returns relevant error:

      iex> input = ~c'''
      ...> <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      ...> <other_message start_time="1730223000000" product="1"
      ...>    event_id="sr:match:52371543" timestamp="1729840401716"/>"
      ...> '''
      iex> UofFeed.Mapper.call(input)
      {:error, :unsupported_message}
  """
  @spec call(xml :: charlist()) ::
          {:ok, FixtureChange.t() | OddsChange.t() | BetCancel.t() | BetStop.t()}
          | {:error, :unsupported_message}
  def call(xml) do
    xml
    |> determine_message_type()
    |> do_process(xml)
  end

  defp do_process("fixture_change", message),
    do: FixtureChange.new(message)

  defp do_process("bet_cancel", message),
    do: BetCancel.new(message)

  defp do_process("bet_stop", message),
    do: BetStop.new(message)

  defp do_process("odds_change", message),
    do: OddsChange.new(message)

  defp do_process("bet_settlement", message),
    do: BetSettlement.new(message)

  defp do_process("alive", message),
    do: Alive.new(message)

  defp do_process(_, _), do: {:error, :unsupported_message}

  defp determine_message_type(xml) do
    xml
    |> SweetXml.xpath(~x"name(/*)")
    |> to_string()
  end
end
