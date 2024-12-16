defmodule UofFeed.Messages.Alive do
  @moduledoc """
  DataSchema representation of an Alive message.

  ### Field list
    - `timestamp` - when the `alive` event was generated,
    - `product` - the producer that generated the message,
    - `subscribed` - 0 - producer is up but not messages arrive (except this one) - restart connection, 1 - everything is ok
  """
  use UofFeed.DataSchema

  @type t :: %__MODULE__{
          timestamp: integer(),
          product: integer(),
          subscribed: integer()
        }

  data_schema(
    field: {:product, "./@product", &Utils.to_integer/1, optional?: false},
    field: {:timestamp, "./@timestamp", &Utils.to_integer/1, optional?: false},
    field: {:subscribed, "./@subscribed", &Utils.to_integer/1, optional?: false}
  )

  @doc ~S"""
  Create new `%Alive{}` strcut based on provided XML.

  ## Examples

      iex> input = '''
      ...> <alive timestamp="1234579" product="2" subscribed="1"/>
      ...> '''
      iex> UofFeed.Messages.Alive.new(input)
      {:ok, %UofFeed.Messages.Alive{
        product: 2,
        timestamp: 1234579,
        subscribed: 1
      }}

  Errors encountered dring data processing will be reported.

      iex> input = '''
      ...> <alive timestamp="invalid" product="2" subscribed="1"/>
      ...> '''
      iex> UofFeed.Messages.Alive.new(input)
      {:error, {[:timestamp], "Invalid data provided, expected integer as string, received: invalid"}}
  """
  @spec new(xml :: String.t()) ::
          {:ok, __MODULE__.t()} | {:error, {access_path :: list(atom()), message :: String.t()}}
  def new(xml) do
    xml
    |> DataSchema.to_struct(__MODULE__)
    |> case do
      {:ok, _} = result -> result
      {:error, ds_errors} -> to_error_tuple(ds_errors)
    end
  end
end
