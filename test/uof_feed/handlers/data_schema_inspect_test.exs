defmodule UofFeed.Handlers.DataSchemaInspectTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  alias UofFeed.Handlers.DataSchemaInspect

  describe "DataSchemaInspect handle_message/1" do
    test "displays message" do
      input = ~c'''
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <fixture_change start_time="1730223000000" product="1" event_id="sr:match:52371543" timestamp="1729840401716" change_type="1" />
      '''

      assert capture_log(fn ->
               assert :ok ==
                        DataSchemaInspect.handle_message(input)
             end) =~ "%UofFeed.Messages.FixtureChange{"
    end
  end
end
