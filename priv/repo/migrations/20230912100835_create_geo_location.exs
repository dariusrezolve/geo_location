defmodule GeoLocation.Repo.Migrations.CreateGeoLocation do
  use Ecto.Migration

  def change do
    create table(:geo_location, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :ip, :string
      add :country_code, :string
      add :country, :string
      add :city, :string
      add :latitude, :decimal
      add :longitude, :decimal
      add :mystery_value, :string
      timestamps()
    end

    create index(:geo_location, [:ip], name: :index_geo_location_on_ip)
  end
end
