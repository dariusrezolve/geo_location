defmodule GeoLocation.Storage.GeoLocation do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          city: String.t(),
          country: String.t(),
          country_code: String.t(),
          ip: String.t(),
          latitude: Decimal.t(),
          longitude: Float.t(),
          mystery_value: Float.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @fields ~w(id city country country_code ip latitude longitude mystery_value inserted_at updated_at)a

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "geo_location" do
    field :city, :string
    field :country, :string
    field :country_code, :string
    field :ip, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :mystery_value, :string

    timestamps()
  end

  def changeset(geo_location, attrs) do
    geo_location
    |> cast(attrs, @fields)
    |> validate_required(@fields -- [:id, :inserted_at, :updated_at])
  end
end
