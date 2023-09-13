defmodule GeoLocationWeb.GeoLocationController do
  use GeoLocationWeb, :controller

  alias Plug.Conn
  alias OpenApiSpex.{Operation, Schema}
  alias GeoLocation.StorageApi, as: Storage
  alias GeoLocationWeb.Controllers.Schemas.{GeoLocation, GenericErrorResp, ErrorsResp}
  alias GeoLocationWeb.Validator

  # this plug doesn't work
  plug OpenApiSpex.Plug.CastAndValidate, render_error: GeoLocation.RenderError

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def get_by_ip_operation() do
    %Operation{
      operationId: "get_geo_location_data",
      summary: "Get GeoLocation data based on IP Address",
      description: "Get GeoLocation data",
      parameters: [
        Operation.parameter(
          :ip,
          :path,
          %Schema{type: :string, format: :ipv4},
          "IP Address to get GeoLocation data for",
          required: true
        )
      ],
      responses: %{
        200 =>
          Operation.response(
            "Geo Location data that matches the IP Address",
            "application/json",
            GeoLocation
          ),
        404 => Operation.response("Not Found", "application/json", ErrorsResp),
        400 => Operation.response("Bad Request", "application/json", ErrorsResp),
        500 => Operation.response("Internal error", "application/json", GenericErrorResp)
      }
    }
  end

  def get_by_ip(conn, params) do
    # do addtional validation here if needed or as a plug
    case Map.get(params, :ip) |> Validator.validate(:ip) do
      {:ok, ip} ->
        case Storage.get_by_ip(ip) do
          nil ->
            conn
            |> put_status(404)
            |> json(%{errors: ["Not Found"]})

          geo_location ->
            conn
            |> put_status(200)
            |> json(geo_location_mapper(geo_location))
        end

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{errors: [reason]})
    end
  end

  defp geo_location_mapper(geo),
    do: %{
      ip: Map.get(geo, :ip),
      country_code: Map.get(geo, :country_code),
      country: Map.get(geo, :country),
      city: Map.get(geo, :city),
      latitude: Map.get(geo, :latitude),
      longitude: Map.get(geo, :longitude),
      inserted_at: Map.get(geo, :inserted_at),
      updated_at: Map.get(geo, :updated_at)
    }

  defmodule GeoLocation.RenderError do
    def init(opts), do: opts

    def call(conn, reason) do
      msg = Jason.encode!(%{error: reason})

      conn
      |> Conn.put_resp_content_type("application/json")
      |> Conn.send_resp(400, msg)
    end
  end
end
