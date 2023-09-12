defmodule GeoLocation.StoreageApi do
  @callback get_by_ip(String.t()) :: list

  def get_by_ip(ip), do: impl().get_by_ip(ip)

  defp impl(), do: Application.get_env(:geo_location, :storage_api, GeoLocation.Storage)
end
