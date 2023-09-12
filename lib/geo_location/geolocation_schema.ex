defmodule GeoLocation.GeoLocationSchema do
  use Ecto.Schema
  import Ecto.Changeset

  # schema used for CSV row validaiton
  embedded_schema do
    field(:ip, :string)
    field(:country_code, :string)
    field(:country, :string)
    field(:city, :string)
    field(:latitude, :float)
    field(:longitude, :float)
    field(:mystery_value, :string, default: "0")
  end

  def changeset(geo_location, attrs) do
    geo_location
    |> cast(attrs, [:ip, :country_code, :country, :city, :latitude, :longitude, :mystery_value])
    |> validate_required([
      :ip,
      :country_code,
      :country,
      :city,
      :latitude,
      :longitude,
      :mystery_value
    ])
    |> validate_length(:ip, min: 7, max: 15)
    |> validate_length(:country_code, min: 2, max: 2)
    |> validate_length(:country, min: 2, max: 50)
    |> custom_validation(:ip)
  end

  # custom format validation for ip, longitude, and latitude, etc
  defp custom_validation(changeset, _field), do: changeset
end
