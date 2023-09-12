defmodule GeoLocationWeb.Controllers.Schemas.ErrorsResp do
  alias OpenApiSpex.Schema
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ErrorsResp",
    type: :object,
    properties: %{
      errors: %Schema{type: :array, items: %Schema{type: :string}}
    },
    required: [:errors],
    additionalProperties: false
  })
end
