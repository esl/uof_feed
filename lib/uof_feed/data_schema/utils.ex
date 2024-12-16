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

      iex> UofFeed.DataSchema.Utils.to_text("test")
      {:ok, "test"}
  """
  @spec to_text(data :: String.t()) :: {:ok, String.t()}
  def to_text(data), do: {:ok, data}

  @doc ~S"""
  Convert provided charlist containing a numeral to a Decimal.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_decimal("1.12")
      {:ok, Decimal.new("1.12")}

      iex> UofFeed.DataSchema.Utils.to_decimal("invalid")
      {:error, "Invalid data provided, expected numeral as string, received: invalid"}
  """
  @spec to_decimal(data :: String.t()) :: {:ok, Decimal.t()} | {:error, String.t()}
  def to_decimal(data) do
    decimal =
      maybe_convert(data, :decimal)

    {:ok, decimal}
  rescue
    Decimal.Error ->
      {:error, "Invalid data provided, expected numeral as string, received: #{data}"}
  end

  @doc ~S"""
  Convert provided charlist to integer value.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_integer("123")
      {:ok, 123}

      iex> UofFeed.DataSchema.Utils.to_integer("invalid")
      {:error, "Invalid data provided, expected integer as string, received: invalid"}

  """
  @spec to_integer(data :: String.t()) :: {:ok, integer()} | {:error, String.t()}
  def to_integer(data) do
    number = maybe_convert(data, :integer)

    {:ok, number}
  rescue
    ArgumentError ->
      {:error, "Invalid data provided, expected integer as string, received: #{data}"}
  end

  @doc ~S"""
  Convert provided charlist to boolean value.

  ## Examples

      iex> UofFeed.DataSchema.Utils.to_boolean("true")
      {:ok, true}

      iex> UofFeed.DataSchema.Utils.to_boolean("false")
      {:ok, false}
  """
  @spec to_boolean(data :: String.t()) :: {:ok, boolean()}
  def to_boolean("true"), do: {:ok, true}
  def to_boolean("false"), do: {:ok, false}
  def to_boolean(_), do: {:ok, nil}

  defp maybe_convert("", _), do: nil
  defp maybe_convert(data, :integer), do: String.to_integer(data)
  defp maybe_convert(data, :decimal), do: Decimal.new(data)
end
