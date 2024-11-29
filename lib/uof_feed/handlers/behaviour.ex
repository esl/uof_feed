defmodule UofFeed.Handlers.Behaviour do
  @moduledoc """
  Behaviour for message handlers.
  Contains default implementation for `handle_message/1`
  """

  defmacro __using__(_) do
    quote do
      @behaviour UofFeed.Handlers.Behaviour
      @impl true
      def handle_message(_message) do
        {:error, :not_implemented}
      end

      defoverridable handle_message: 1
    end
  end

  @callback handle_message(charlist()) :: :ok
end
