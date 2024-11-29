defmodule UofFeed.DataSchema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import DataSchema, only: [data_schema: 1]
      import DataSchema.Errors, only: [to_error_tuple: 1]
      alias UofFeed.DataSchema.Utils
      alias UofFeed.Messages.Types
      @data_accessor UofFeed.DataSchema.XmlAccessor
      @options [optional?: true, empty_values: [nil, "", []], default: &Utils.default_empty/0]
    end
  end
end
