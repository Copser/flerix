defmodule Flerix.Config do
  @moduledoc """
  Reads configuration on application start, parses all environment variables (if any)
  and caches the final config in memory to avoid parsing on each read afterwards.
  """
  use GenServer

  @config_keys ~w(
    cloudflare_url
    api_token
    account_id
    x_auth_key
    x_auth_email
  )a

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    config =
      @config_keys
      |> Enum.map(fn key -> {key, get_config_value(key)} end)
      |> Map.new()

    {:ok, config}
  end

  def get_cloudflare_url, do: get(:cloudflare_url)

  def get_api_token, do: get(:api_token)

  def get_account_id, do: get(:account_id)

  def get_x_auth_key, do: get(:x_auth_key)

  def get_x_auth_email, do: get(:x_auth_email)

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  def put(key, value), do: GenServer.call(__MODULE__, {:put, key, value})

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    {:reply, value, Map.put(state, key, value)}
  end

  defp get_config_value(key) do
    :flerix
    |> Application.get_env(key)
    |> parse_config_value()
  end

  defp parse_config_value({:system, env_name}), do: fetch_env!(env_name)

  defp parse_config_value({:system, :integer, env_name}) do
    env_name
    |> fetch_env!()
    |> String.to_integer()
  end

  defp parse_config_value(value), do: value

  # System.fetch_env!/1 support for older versions of Elixir
  defp fetch_env!(env_name) do
    case System.get_env(env_name) do
      nil ->
        raise ArgumentError,
          message: "could not fetch environment variable \"#{env_name}\" because it is not set"

      value ->
        value
    end
  end
end
