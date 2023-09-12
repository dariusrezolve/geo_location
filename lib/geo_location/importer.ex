defmodule GeoLocation.Importer do
  alias NimbleCSV.RFC4180, as: CSV
  alias GeoLocation.GeoLocationSchema, as: CsvGeoLocation
  alias GeoLocation.StorageApi, as: Storage
  alias GeoLocation.Storage.GeoLocation

  def import data_stream do
    {time_microsec, result} = :timer.tc(fn -> do_import(data_stream) end)

    %{time: time_microsec / 1_000_000, result: result}
  end

  def do_import(data_stream) do
    data_stream
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      parse_csv_row(row)
    end)
    |> Flow.partition(window: Flow.Window.global() |> Flow.Window.trigger_every(get_batch_size()))
    |> Flow.reduce(fn -> reset_acc() end, fn row, acc ->
      partition_rows_by_validity(row, acc.valid, acc.invalid)
    end)
    |> Flow.on_trigger(fn %{valid: valid, invalid: invalid}, index, _window ->
      # we can add additional error checking here and add the rows that failed to import to the invalid list
      insert_into_db(valid)

      result = %{
        valid: %{count: valid |> Enum.count()},
        invalid: %{count: invalid |> Enum.count(), rows: invalid}
      }

      {[result], reset_acc()}
    end)
    |> Flow.partition(stages: 1)
    |> Flow.reduce(fn -> aggregate_acc() end, fn %{
                                                   valid: valid,
                                                   invalid: invalid
                                                 },
                                                 acc ->
      %{
        valid: %{count: valid.count + acc.valid.count},
        invalid: %{
          count: invalid.count + acc.invalid.count,
          rows: acc.invalid.rows ++ invalid.rows
        }
      }
    end)
    |> Enum.into(%{})
  end

  defp parse_csv_row(row) do
    [tokenized_row] = CSV.parse_string(row, skip_headers: false)

    %{
      ip: Enum.at(tokenized_row, 0),
      country_code: Enum.at(tokenized_row, 1),
      country: Enum.at(tokenized_row, 2),
      city: Enum.at(tokenized_row, 3),
      latitude: Enum.at(tokenized_row, 4),
      longitude: Enum.at(tokenized_row, 5),
      mystery_value: Enum.at(tokenized_row, 6)
    }
  end

  ###
  # partition rows into valid and invalid
  defp partition_rows_by_validity(row, valid \\ [], invalid \\ []) do
    csvChangeset = CsvGeoLocation.changeset(%CsvGeoLocation{}, row)

    case csvChangeset.valid?() do
      true ->
        %{valid: [row | valid], invalid: invalid}

      false ->
        %{valid: valid, invalid: [row | invalid]}
    end
  end

  defp insert_into_db(valid) do
    valid
    |> Enum.map(fn row ->
      %{
        ip: row.ip,
        country_code: row.country_code,
        country: row.country,
        city: row.city,
        latitude: row.latitude,
        longitude: row.longitude,
        mystery_value: row.mystery_value,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)
    |> Storage.insert_batch()
  end

  defp reset_acc(), do: %{valid: [], invalid: []}
  defp aggregate_acc(), do: %{valid: %{count: 0}, invalid: %{count: 0, rows: []}}

  # Application.get_env(:geo_location, :batch_size, 10000)
  defp get_batch_size(), do: 5000
end
