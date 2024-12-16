defmodule UofFeed.Handlers.XMLInspectTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  alias UofFeed.Handlers.XMLInspect

  describe "XmlInspect handle_message/1" do
    test "displays message" do
      assert capture_log(fn -> assert :ok == XMLInspect.handle_message("XML Inspect Test") end) =~
               "XML Inspect Test"
    end
  end
end
