defmodule Testly.SmartProxy.Proxier do
  use GenServer

  alias __MODULE__
  alias HTTPotion.{AsyncResponse, AsyncChunk, AsyncEnd, AsyncTimeout, AsyncHeaders}
  alias Testly.SmartProxy.{ProxyHeaders, ProxyChunk, ProxyEnd, ProxyError, ProxyTimeout}
  alias Testly.SmartProxy.CssUrlReplacer.Replacer

  @type to_proxy_url :: (String.t() -> String.t())
  @type option :: {:url, String.t()} | {:to_proxy_url, to_proxy_url()} | {:stream_to, pid()}

  defstruct [:stream_to, :transformer, :url, previous_part_of_chunk: ""]

  @spec new([option()]) :: GenServer.on_start()
  def new(opts) do
    GenServer.start(Proxier, opts)
  end

  @spec start_stream(pid()) :: :ok | ProxyError.t()
  def start_stream(pid) do
    GenServer.call(pid, :start)
  end

  @spec stop_stream(pid()) :: :ok
  def stop_stream(pid) do
    GenServer.stop(pid)
  end

  @impl true
  def init(to_proxy_url: to_proxy_url, url: url, stream_to: stream_to) do
    ext = Path.extname(URI.parse(url).path)

    transformer = fn data, is_end: is_end -> transform_chunk(ext, data, to_proxy_url, is_end: is_end) end

    {:ok,
     %Proxier{
       transformer: transformer,
       stream_to: stream_to,
       url: url
     }}
  end

  @impl true
  def handle_call(:start, _pid, state) do
    case HTTPotion.get(state.url,
           stream_to: self(),
           headers: [
             "User-Agent":
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
             Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
             # "Accept-Encoding": "gzip",
             "Cache-Control": "no-cache",
             Connection: "keep-alive",
             DNT: "1",
             Pragma: "no-cache"
           ]
         ) do
      %AsyncResponse{} ->
        {:reply, :ok, state}

      error ->
        {:reply, %ProxyError{message: error.message}, state}
    end
  end

  @impl true
  def handle_info(%AsyncChunk{chunk: chunk}, %Proxier{transformer: transformer} = state) do
    {transformed, not_transformed} = transformer.(state.previous_part_of_chunk <> chunk, is_end: false)

    if transformed != "" do
      send(state.stream_to, %ProxyChunk{chunk: transformed})
    end

    {:noreply, %Proxier{state | previous_part_of_chunk: not_transformed}}
  end

  @impl true
  def handle_info(%AsyncEnd{}, %Proxier{transformer: transformer} = state) do
    if state.previous_part_of_chunk != "" do
      {transformed, ""} = transformer.(state.previous_part_of_chunk, is_end: true)

      send(state.stream_to, %ProxyChunk{chunk: transformed})
    end

    send(state.stream_to, %ProxyEnd{})

    {:noreply, state}
  end

  @impl true
  def handle_info(%AsyncTimeout{}, state) do
    send(state.stream_to, %ProxyTimeout{})

    {:noreply, state}
  end

  @impl true
  def handle_info(%AsyncHeaders{status_code: status_code, headers: headers}, state) do
    send(state.stream_to, %ProxyHeaders{status_code: status_code, headers: headers.hdrs})

    {:noreply, state}
  end

  @impl true
  def handle_info({_ref, {:error, message}}, state) do
    message =
      if is_tuple(message) do
        elem(message, 0)
      else
        message
      end

    send(state.stream_to, %ProxyError{message: message})

    {:stop, :normal, state}
  end

  @spec transform_chunk(
          String.t(),
          String.t(),
          to_proxy_url(),
          is_end: boolean()
        ) :: {String.t(), String.t()}
  defp transform_chunk(".css", data, proxy_url, is_end: is_end) do
    Replacer.replace(data, proxy_url, is_end: is_end)
  end

  defp transform_chunk(_, data, _proxy_url, is_end: _is_end) do
    {data, ""}
  end
end
