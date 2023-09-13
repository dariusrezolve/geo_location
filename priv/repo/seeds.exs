alias GeoLocation.Importer

{time, result} =
  :timer.tc(fn ->
    "priv/data_dump.csv"
    |> File.stream!(read_ahead: 50_000)
    |> Importer.import()

    :ok
  end)

(time / 1000) |> IO.inspect(label: "Elapsed time (ms)")
result |> IO.inspect(label: "Result")
