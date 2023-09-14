alias GeoLocation.Importer

%{time: time, result: result} =
  "priv/data_dump.csv"
  |> File.stream!(read_ahead: 50_000)
  |> Importer.import()

time |> IO.inspect(label: "Elapsed time (sec)")
result |> IO.inspect(label: "Result")
