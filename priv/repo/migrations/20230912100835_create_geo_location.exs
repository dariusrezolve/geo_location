defmodule GeoLocation.Repo.Migrations.CreateGeoLocation do
  use Ecto.Migration

  def change do
    create table(:geo_locations) do
      add :ip, :string
      add :country_code, :string
      add :country, :string
      add :city, :string
      add :latitude, :string
      add :longitude, :string
      add :mystery_value, :string
      timestamps()
    end

    create index(:geo_locations, [:ip], name: :index_geo_location_on_ip, unique: true)
  end
end
