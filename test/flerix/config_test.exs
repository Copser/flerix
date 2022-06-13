defmodule Flerix.ConfigTest do
  use ExUnit.Case, async: false

  alias Flerix.Config

  describe "init/1" do
    test "use default values if no other specified" do
      :ok = Application.stop(:flerix)
      {:ok, _} = Application.ensure_all_started(:flerix)

      assert Config.get_cloudflare_url() == "api.cloudflare.com/client/v4/accounts"
      assert Config.get_api_token() == nil
    end

    test "use values from config if present" do
      :ok = Application.stop(:flerix)

      set_config(%{
        cloudflare_url: "api.cloudflare.com/client/v4/accounts",
        x_auth_email: "dev1@example.com",
      })

      {:ok, _} = Application.ensure_all_started(:flerix)

      assert Config.get_cloudflare_url() == "api.cloudflare.com/client/v4/accounts"
      assert Config.get_x_auth_email() == "dev1@example.com"
    end

    test "reads env variables when {:system, _} typle is used" do
      :ok = Application.stop(:flerix)

      set_config(%{
        cloudflare_url: {:system, "CLOUDFLARE_URL"},
        x_auth_email: {:system, "X_AUTH_EMAIL"},
      })

      set_envs(%{
        "CLOUDFLARE_URL" => "api.cloudflare.com/client/v4/accounts",
        "X_AUTH_EMAIL" => "dev1@example.com",
      })

      {:ok, _} = Application.ensure_all_started(:flerix)

      assert Config.get_cloudflare_url() == "api.cloudflare.com/client/v4/accounts"
      assert Config.get_x_auth_email() == "dev1@example.com"
    end

    test "fails to start when {:system, _} tuple is used but env is missing" do
      :ok = Application.stop(:flerix)

      set_config(%{
        cloudflare_url: {:system, "CLOUDFLARE_URL"},
        x_auth_email: {:system, "X_AUTH_EMAIL"},
      })

      assert {:error,
              {:flerix,
               {{:shutdown,
                 {:failed_to_start_child, Flerix.Config,
                  {%ArgumentError{
                     message:
                       "could not fetch environment variable \"CLOUDFLARE_URL\" because it is not set"
                   }, _}}},
                {Flerix, :start, [:normal, []]}}}} = Application.ensure_all_started(:flerix)
    end
  end

  defp set_config(values) do
    config = Application.get_all_env(:flerix)

    for {k, v} <- values do
      Application.put_env(:flerix, k, v)
    end

    on_exit(fn ->
      for {key, _value} <- values do
        Application.put_env(:flerix, key, Keyword.get(config, key))
      end

      {:ok, _} = Application.ensure_all_started(:flerix)
    end)
  end

  defp set_envs(envs) do
    for {key, value} <- envs do
      System.put_env(key, value)
    end

    on_exit(fn ->
      for {key, _value} <- envs do
        System.delete_env(key)
      end
    end)
  end
end
