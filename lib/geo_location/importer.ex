defmodule GeoLocation.Importer do
  alias NimbleCSV.RFC4180, as: CSV
  alias GeoLocation.GeoLocationSchema, as: CsvGeoLocation
  alias GeoLocation.StorageApi, as: Storage
  alias GeoLocation.Storage.GeoLocation

  def import(data_stream) do
    data_stream
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        ip: Enum.at(row, 0),
        country_code: Enum.at(row, 1),
        country: Enum.at(row, 2),
        city: Enum.at(row, 3),
        latitude: Enum.at(row, 4),
        longitude: Enum.at(row, 5),
        mystery_value: Enum.at(row, 6)
      }
    end)
    |> Flow.partition(window: Flow.Window.global() |> Flow.Window.trigger_every(get_batch_size()))
    |> Flow.reduce(fn -> %{valid: [], invalid: []} end, fn row, acc ->
      csvChangeset = CsvGeoLocation.changeset(%CsvGeoLocation{}, row)

      case csvChangeset.valid?() do
        true ->
          %{valid: [row | acc.valid], invalid: acc.invalid}

        false ->
          %{valid: acc.valid, invalid: [row | acc.invalid]}
      end
    end)
    |> Flow.on_trigger(fn r, index, _window ->
      # insert into DB as batches as each trigger is called
      # insert only the valid rows
      r = %{valid: r.valid, invalid: r.invalid ++ [%{city: index}]}

      {[r], []}
    end)
    |> Flow.partition(stages: 1)
    |> Flow.reduce(fn -> %{valid: [], invalid: []} end, fn %{valid: valid, invalid: invalid},
                                                           acc ->
      %{valid: valid ++ acc.valid, invalid: invalid ++ acc.invalid}
    end)
    |> Enum.to_list()
  end

  defp get_batch_size(), do: Application.get_env(:geo_location, :batch_size, 10)
end
