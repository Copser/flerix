defmodule Flerix.ResponseFormatter do
  @moduledoc """
  Provides functions to normalize and simplify HTTP Responses received
  """
  def format_response({:ok, %{body: {:ok, %{"error" => error}}}}) do
    {:error, error}
  end
  def format_response({:ok, %{body: body}}), do: body
  def format_response({:error, error}), do: {:error, error}
end
