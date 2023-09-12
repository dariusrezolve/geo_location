defmodule GeoLocation.Repo do
  use Ecto.Repo,
    otp_app: :geo_location,
    adapter: Ecto.Adapters.Postgres
end
