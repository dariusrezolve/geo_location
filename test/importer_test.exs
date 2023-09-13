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
    import()

    result = Storage.get_by_ip("200.106.141.15")

    assert result |> Enum.count() == 1
  end

  test "returns an error on malformed CVS file" do
    %{result: %{invalid: invalid, valid: valid}}

    "test/fixtures/data_dump_test_malformed.csv"
    |> File.stream!(read_ahead: 50_000)
    |> Importer.import()

    assert invalid.count == 2
    assert valid.count == 16
  end

  defp data_dump_csv(), do: "test/fixtures/data_dump_test.csv"
end
