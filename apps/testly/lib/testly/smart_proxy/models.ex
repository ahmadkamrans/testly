defmodule Testly.SmartProxy.ProxyHeaders do
    defstruct [:status_code, :headers]
end

defmodule Testly.SmartProxy.ProxyChunk do
  defstruct [:chunk]
end

defmodule Testly.SmartProxy.ProxyEnd do
  defstruct []
end

defmodule Testly.SmartProxy.ProxyError do
  defexception [:message]
end

defmodule Testly.SmartProxy.ProxyTimeout do
  defstruct []
end
