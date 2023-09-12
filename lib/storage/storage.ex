defmodule GeoLocation.Storage do
  import Ecto.Query
  alias GeoLocation.Repo

  def get_by_ip(ip) do
    GeoLocation
    |> where([g], g.ip == ^ip)
    |> Repo.all()
  end

  def insert_batch(rows) do
    Repo.insert_all(GeoLocation, rows,
      on_conflict: :replace_all,
      conflict_target: [
        :ip,
        :country_code,
        :country,
        :city,
        :latitude,
        :longitude,
        :mystery_value
      ]
    )
  end
end
