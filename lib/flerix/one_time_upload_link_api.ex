defmodule Flerix.OneTimeUploadLinkApi do
  @moduledoc false
  use HTTPoison.Base

  alias Flerix.Config

  def process_url("https://" <> _ = url), do: url
  def process_url(url), do: Config.get_cloudflare_url() <> "/#{Config.get_account_id}" <> url
  def process_response_body(body), do: JSON.decode(body)
end
