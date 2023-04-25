defmodule Testly.SmartProxy do
  @moduledoc """
  Testly.SmartProxy keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Testly.SmartProxy.CssUrlReplacer.Replacer
  alias Testly.SmartProxy.Proxier
  alias __MODULE__
  alias Testly.SmartProxy.CssUrlReplacer.AbsoluteUrl

  @type start_proxy_stream_opts :: {:recording_id, String.t()} | {:current_url, String.t()} | {:stream_to, pid()}

  defmodule Behaviour do
    @callback start_proxy_stream([SmartProxy.start_proxy_stream_opts()]) ::
                {pid(), :ok | Testly.SmartProxy.ProxyError.t()}
    @callback stop_proxy_stream(pid()) :: :ok
  end

  @behaviour Behaviour

  @spec generate_url(String.t(), String.t(), String.t()) :: String.t()
  def generate_url(recording_id, url, origin_url) do
    absolute_url =
      case URI.parse(url) do
        %URI{authority: nil} -> AbsoluteUrl.generate(origin_url, url)
        _ -> url
      end

    proxy_url()
    |> String.replace(":recording_id", URI.encode_www_form(recording_id))
    |> String.replace(":url", URI.encode_www_form(absolute_url))
  end

  @spec replace_css_urls(String.t(), String.t(), String.t()) :: String.t()
  def replace_css_urls(css, recording_id, origin_url) do
    {replaced_css, ""} =
      Replacer.replace(
        css,
        &generate_url(recording_id, &1, origin_url),
        is_end: true
      )

    replaced_css
  end

  @impl true
  def start_proxy_stream(
        recording_id: recording_id,
        current_url: current_url,
        stream_to: stream_to
      ) do
    {:ok, pid} =
      Proxier.new(
        to_proxy_url: &generate_url(recording_id, &1, current_url),
        url: current_url,
        stream_to: stream_to
      )

    {pid, Proxier.start_stream(pid)}
  end

  @impl true
  def stop_proxy_stream(pid) do
    Proxier.stop_stream(pid)
  end

  defp proxy_url do
    Keyword.fetch!(Application.fetch_env!(:testly, __MODULE__), :proxy_url)
  end
end
