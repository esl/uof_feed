defmodule UofFeed.DataSchema.Utils do
  @moduledoc """
  Utility functions for data transformation.
  """

  @doc """
  Provide default empty value for DataSchema structs.
  """
  @spec default_empty :: nil
  def default_empty, do: nil

  @doc """
  Convert provided charlist to string.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_text(~c"test")
      {:ok, "test"}
  """
  @spec to_text(data :: charlist()) :: {:ok, String.t()}
  def to_text(data), do: {:ok, to_string(data)}

  @doc ~S"""
  Convert provided charlist to float represented by Decimal.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_decimal(~c"1.12")
      {:ok, Decimal.new("1.12")}

      iex> UofFeed.DataSchema.Utils.to_decimal(~c"invalid")
      {:error, "Invalid data provided, expected float as string, received: invalid"}
  """
  @spec to_decimal(data :: charlist()) :: {:ok, Decimal.t()} | {:error, String.t()}
  def to_decimal(data) do
    decimal =
      data
      |> to_string()
      |> maybe_convert(:decimal)

    {:ok, decimal}
  rescue
    Decimal.Error ->
      {:error, "Invalid data provided, expected float as string, received: #{data}"}
  end

  @doc ~S"""
  Convert provided charlist to integer value.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_integer(~c"123")
      {:ok, 123}

      iex> UofFeed.DataSchema.Utils.to_integer(~c"invalid")
      {:error, "Invalid data provided, expected integer as string, received: invalid"}

  """
  @spec to_integer(data :: charlist()) :: {:ok, integer()} | {:error, String.t()}
  def to_integer(data) do
    number =
      data
      |> to_string()
      |> maybe_convert(:integer)

    {:ok, number}
  rescue
    ArgumentError ->
      {:error, "Invalid data provided, expected integer as string, received: #{data}"}
  end

  @doc ~S"""
  Convert provided charlist to boolean value.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_boolean(~c'true')
      {:ok, true}

      iex> UofFeed.DataSchema.Utils.to_boolean(~c'false')
      {:ok, false}
  """
  @spec to_boolean(data :: charlist()) :: {:ok, boolean()}
  def to_boolean(data) when data == ~c"true", do: {:ok, true}
  def to_boolean(data) when data == ~c"false", do: {:ok, false}
  def to_boolean(_), do: {:ok, nil}

  defp maybe_convert("", _), do: nil
  defp maybe_convert(data, :integer), do: String.to_integer(data)
  defp maybe_convert(data, :decimal), do: Decimal.new(data)
end
