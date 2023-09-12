defmodule GeoLocation.ImporterTest do
  use GeoLocation.DataCase
  alias GeoLocation.Importer

  def import() do
    data_dump_csv()
    |> File.stream!(read_ahead: 50_000)
    |> Importer.import()
  end

  test "imports all lines and filters out invalid data" do
    # :timer.tc(&import/0) |> IO.inspect(label: "import_real")
    # add better test here
    [invalid: invalid, valid: valid] = import()
    valid |> IO.inspect(label: "valid")
    invalid |> IO.inspect(label: "invalid")
    assert invalid |> Enum.count() == 2
  end

  # for duplicates, we will need to add a unique constraint to the database and rely on that
  # this is because we will need to check uniquenes between several file imports anyway
  test "imports all lines and filters out duplicates" do
    # :timer.tc(&import/0) |> IO.inspect(label: "import_real")
    result = import() |> IO.inspect(label: "import_real")
    %{invalid_rows: invalid_rows, valid_rows: valid_rows} = import()
    invalid_rows |> IO.inspect(label: "invalid_rows")
    valid_rows |> IO.inspect(label: "valid_rows")

    assert valid_rows |> Enum.count() == 14
  end

  defp data_dump_csv(), do: "test/fixtures/data_dump_test.csv"
end
