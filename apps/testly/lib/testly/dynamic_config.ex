defmodule GeolixInit do
  def init do
    databases = [
      %{
        id: :cities_db,
        adapter: Geolix.Adapter.MMDB2,
        source: Application.app_dir(:testly, ["priv", "geo", "GeoLite2-City_20181016.tar.gz"])
      }
    ]

    Application.put_env(:geolix, :databases, databases)
  end
end

defmodule UAInspectorInit do
  def init do
    path = Application.app_dir(:testly, ["priv", "user_agent"])

    Application.put_env(:ua_inspector, :database_path, path)
  end
end

defmodule RefInspectorInit do
  def init do
    path = Application.app_dir(:testly, ["priv", "referrer"])

    Application.put_env(:ref_inspector, :database_path, path)
  end
end
