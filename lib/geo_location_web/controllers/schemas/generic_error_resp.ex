defmodule GeoLocationWeb.Controllers.Schemas.GenericErrorResp do
  alias OpenApiSpex.Schema
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "GenericErrorResp",
    type: :object,
    properties: %{
      error: %Schema{type: :string}
    },
    required: [:error],
    additionalProperties: false
  })
end
