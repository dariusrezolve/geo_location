defmodule GeoLocation.Storage do
  @behaviour GeoLocation.StorageApi
  import Ecto.Query
  alias GeoLocation.Repo
  alias GeoLocation.Storage.GeoLocation

  @spec get_by_ip(String.t()) :: GeoLocation.t() | nil
  def get_by_ip(ip) do
    GeoLocation
    |> where([g], g.ip == ^ip)
    |> Repo.one()
  end

  @spec insert_batch(list()) :: {non_neg_integer(), nil | [term()]}
  def insert_batch(rows) do
    # TODO custom insert_all + select * from unnest(values(...))
    #
    Repo.insert_all(GeoLocation, rows,
      on_conflict: :nothing,
      conflict_target: [
        :ip
      ]
    )
  end
end
