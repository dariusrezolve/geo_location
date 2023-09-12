defmodule GeoLocationWeb.GeoLocationController do
  use GeoLocationWeb, :controller
  alias OpenApiSpex.{Operation, Schema}
  alias GeoLocation.StorageApi, as: Storage
  alias GeoLocationWeb.Controllers.Schemas.{GeoLocation, GenericErrorResp}

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
          %Schema{type: :integer},
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
    params |> IO.inspect(label: "params")

    case Storage.get_by_ip("123") do
      {:ok, geo_location} ->
        conn
        |> put_status(:ok)
        |> json(%{geo_location: geo_location})

      [] ->
        conn
        |> put_status(404)
        |> json(%{errors: ["Not Found"]})

      _ ->
        conn
        |> put_status(500)
        |> render("error.json", message: "Not Found")
    end
  end
end

defmodule GeoLocation.RenderError do
  def init(opts), do: opts

  def call(conn, reason) do
    msg = Jason.encode!(%{error: reason})

    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(400, msg)
  end
end
