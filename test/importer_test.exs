defmodule GeoLocation.ImporterTest do
  use GeoLocation.DataCase
  alias GeoLocation.Importer
  alias GeoLocation.Storage

  def import() do
    data_dump_csv()
    |> File.stream!(read_ahead: 50_000)
    |> Importer.import()
  end

  test "imports all lines and filters out invalid data" do
    %{result: %{invalid: invalid, valid: valid}} = import()
    assert invalid.count == 2
    assert valid.count == 16
  end

  test "imports all lines and filters out duplicates" do
    assert nil == Storage.get_by_ip("200.106.141.15")

    import()

    result = Storage.get_by_ip("200.106.141.15")

    assert result != nil
  end

  test "returns an error on malformed CVS file" do
    %{result: %{valid: valid, invalid: invalid}} =
      "test/fixtures/bad_data_dump_test.csv"
      |> File.stream!(read_ahead: 50_000)
      |> Importer.import()

    assert invalid.count == 1
    assert valid.count == 0
  end

  defp data_dump_csv(), do: "test/fixtures/data_dump_test.csv"
end
