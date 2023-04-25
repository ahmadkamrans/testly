defmodule TestlyAPI.Schema.SessionRecording.DeviceType do
  use Absinthe.Schema.Notation

  alias Testly.SessionRecordings.Device

  # Testly.SessionRecordings.DeviceTypeEnum.__enum_map__()
  enum(:device_type,
    values: [
      :desktop,
      :mobile,
      :tablet
    ]
  )

  object :device_browser do
    field(:name, :string)
    field(:version, :string)
  end

  object :device_os do
    field(:name, :string)
    field(:version, :string)
  end

  object :session_recording_device do
    field(:id, non_null(:uuid4))

    field(:user_agent, non_null(:string))
    field(:screen_height, non_null(:integer))
    field(:screen_width, non_null(:integer))
    field(:type, non_null(:device_type))

    field :browser, non_null(:device_browser) do
      resolve(fn %Device{} = device, _args, _resolution ->
        {:ok,
         %{
           name: device.browser_name,
           version: device.browser_version
         }}
      end)
    end

    field :os, non_null(:device_os) do
      resolve(fn %Device{} = device, _args, _resolution ->
        {:ok,
         %{
           name: device.os_name,
           version: device.os_version
         }}
      end)
    end
  end
end
