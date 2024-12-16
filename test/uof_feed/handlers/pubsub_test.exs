defmodule UofFeed.Handlers.PubSubTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Phoenix.PubSub
  alias UofFeed.Handlers.PubSub, as: Handler
  alias UofFeed.Messages.FixtureChange

  describe "PubSub handle_message/1" do
    test "publishes message on 'uof-feed-messages' topic" do
      PubSub.subscribe(UofFeed.PubSub, "uof-feed-messages")

      message = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?><fixture_change start_time="1730223000000" product="1" event_id="sr:match:52371543" timestamp="1729840401716"/>
      """

      expected_payload = %FixtureChange{
        change_type: nil,
        start_time: 1_730_223_000_000,
        product: 1,
        event_id: "sr:match:52371543",
        timestamp: 1_729_840_401_716
      }

      Handler.handle_message(message)
      assert_receive ^expected_payload
    end

    test "prints error when message parsing fails" do
      message = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?><fixture_change start_time="invalid" product="1" event_id="sr:match:52371543" timestamp="1729840401716"/>
      """

      assert capture_log(fn -> assert :ok == Handler.handle_message(message) end) =~
               "Invalid data provided, expected integer as string, received: invalid"
    end
  end
end
