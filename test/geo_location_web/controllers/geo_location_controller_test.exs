defmodule GeoLocationWeb.GeoLocationControllerTest do
  use GeoLocationWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

  test "GET /api/inexistent_ip", %{conn: conn} do
    GeoLocation.MockedStorageApi
    |> expect(:get_by_ip, fn _ip -> nil end)

    conn = get(conn, ~p"/api/123.123.123.123")
    assert json_response(conn, 404)
  end

  test "GET /api/badipformat", %{conn: conn} do
    conn = get(conn, ~p"/api/badipformat")
    assert json_response(conn, 400)
  end

  test "GET /api/valid_ip", %{conn: conn} do
    GeoLocation.MockedStorageApi
    |> expect(:get_by_ip, fn _ip -> %{} end)

    conn = get(conn, ~p"/api/123.123.123.213")
    assert json_response(conn, 200)
  end
end
