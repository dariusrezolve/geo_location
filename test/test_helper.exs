ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(GeoLocation.Repo, :manual)
Mox.defmock(GeoLocation.MockedStorageApi, for: GeoLocation.StorageApi)

Application.put_env(:geo_location, :storage_api, GeoLocation.MockedStorageApi)
