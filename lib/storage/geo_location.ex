defmodule GeoLocation.Storage.GeoLocation do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          city: String.t(),
          country: String.t(),
          country_code: String.t(),
          ip: String.t(),
          latitude: String.t(),
          longitude: String.t(),
          mystery_value: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @fields ~w(city country country_code ip latitude longitude mystery_value inserted_at updated_at)a

  schema "geo_locations" do
    field :city, :string
    field :country, :string
    field :country_code, :string
    field :ip, :string
    field :latitude, :string
    field :longitude, :string
    field :mystery_value, :string

    timestamps()
  end

  def changeset(geo_location, attrs) do
    geo_location
    |> cast(attrs, @fields)
    |> validate_required(@fields -- [:inserted_at, :updated_at])
  end
end
