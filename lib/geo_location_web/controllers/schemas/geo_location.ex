defmodule GeoLocationWeb.Controllers.Schemas.GeoLocation do
  alias OpenApiSpex.Schema
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "GeoLocation",
    type: :object,
    properties: %{
      ip: %Schema{type: :string},
      country_code: %Schema{type: :string},
      country: %Schema{type: :string},
      city: %Schema{type: :string},
      latitude: %Schema{type: :string},
      longitude: %Schema{type: :string},
      inserted_at: %Schema{type: :string, format: :date_time},
      updated_at: %Schema{type: :string, format: :date_time}
    },
    additionalProperties: false,
    example: %{
      ip: "123.123.123.123",
      country_code: "US",
      country: "United States",
      city: "New York",
      latitude: "40.71427",
      longitude: "-74.00597",
      inserted_at: "2020-01-01T00:00:00Z",
      updated_at: "2020-01-01T00:00:00Z"
    }
  })
end
