defmodule GeoLocation.StorageApi do
  @callback get_by_ip(String.t()) :: list
  @callback insert_batch(list) :: :ok

  def get_by_ip(ip), do: impl().get_by_ip(ip)
  def insert_batch(rows), do: impl().insert_batch(rows)

  defp impl(), do: Application.get_env(:geo_location, :storage_api, GeoLocation.Storage)
end
