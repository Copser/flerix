defmodule Flerix do
  @moduledoc """
  Documentation for `Flerix`.
  """
  use Application

  alias Flerix.Config
  alias Flerix.OneTimeUploadLinkApi
  alias Flerix.ResponseFormatter

  def start(_type, _args) do
    children = [Config]
    opts = [strategy: :one_for_one, name: Flerix.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @type resp :: {:ok, Map.t()} | {:error, Map.t()}
  @type upload_length :: non_neg_integer()

  def set_x_auth_email do
    Config.get_x_auth_email()
  end

  def set_x_auth_key do
    Config.get_x_auth_key()
  end

  @spec get_one_time_upload_link(upload_length) :: resp
  def get_one_time_upload_link(upload_length) do
    headers = [
      {:"Tus-Resumable", "1.0.0"},
      {:"Upload-Length", upload_length},
      {:"X-Auth-Email", set_x_auth_email()},
      {:"X-Auth-Key", set_x_auth_key()},
      {:"Content-Type", "application/json"},
    ]

    ~s(/stream?direct_user=true)
    |> OneTimeUploadLinkApi.post("", headers)
    |> ResponseFormatter.format_response()
  end
end
