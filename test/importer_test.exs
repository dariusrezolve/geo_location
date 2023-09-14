defmodule GeoLocation.ImporterTest do
  use GeoLocation.DataCase
  alias GeoLocation.Importer
  alias GeoLocation.StorageApi
  alias GeoLocation.ImportFlow
  alias GeoLocation.Importer
  import Mox

  setup do
    Application.put_env(:geo_location, :storage_api, GeoLocation.Storage)
    :ok
  end

  def import() do
    data_dump_csv()
    |> File.stream!(read_ahead: 50_000)
    |> ImportFlow.import()
  end

  test "imports all lines and filters out invalid data" do
    # %{result: %{valid: valid, invalid: invalid}} = import()
    data_dump_csv()
    |> File.stream!(read_ahead: 50_000)
    |> Importer.start_flow(self())

    assert_receive({:ok, %{result: %{valid: valid, invalid: invalid}}})
    assert invalid.count == 2
    assert valid.count == 16
  end

  test "imports all lines and filters out duplicates" do
    assert nil == StorageApi.get_by_ip("200.106.141.15")
    import()
    result = StorageApi.get_by_ip("200.106.141.15")

    assert result != nil
  end

  test "returns no valid rows on malformed CSV file" do
    %{result: %{valid: valid, invalid: invalid}} =
      "test/fixtures/bad_data_dump_test.csv"
      |> File.stream!(read_ahead: 50_000)
      |> ImportFlow.import()

    assert invalid.count == 1
    assert valid.count == 0
  end

  test "import process fails but doesn't take down the caller" do
    Application.put_env(:geo_location, :storage_api, GeoLocation.MockedStorageApi)

    GeoLocation.MockedStorageApi
    |> expect(:insert_batch, System.schedulers(), fn _ ->
      raise "oops"
      :ok
    end)

    assert Process.whereis(GeoLocation.Importer) != nil

    data_dump_csv()
    |> File.stream!(read_ahead: 50_000)
    |> Importer.start_flow(self())

    assert_receive :error
    assert Process.whereis(GeoLocation.Importer) != nil
  end

  defp data_dump_csv(), do: "test/fixtures/data_dump_test.csv"
end
