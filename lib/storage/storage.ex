defmodule GeoLocation.Storage do
  import Ecto.Query
  alias GeoLocation.Repo
  alias GeoLocation.Storage.GeoLocation

  def get_by_ip(ip) do
    GeoLocation
    |> where([g], g.ip == ^ip)
    |> Repo.one()
  end

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
