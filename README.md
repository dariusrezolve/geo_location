
# GeoLocation
The requirements for this application are located at https://github.com/viodotcom/backend-assignment-elixir#readme

The main tasks are as follows:
* Import/Parse a CVS file (presumably large). Handle duplicates.
* Add the parsed data into a DB in an efficient manner
* Give some statistics about the process (elapsed time, valid/invalid rows)

#### Parse and validate the CVS file
The issues here are mainly due to the size of the file. To avoid high memory consumption, we can't read the whole file at once and process it in memory. A solution would be to use Streams and process the file row by row with minimum memory overhead. We can improve this solution by adding a layer of concurrency to the processing, as the actual parsing/validation depends only on the row itself.

#### Import parsed data
Importing large quantities of data can also create overhead at DB level. To avoid unnecessary round trips, we can choose to import the data in batches.

#### Handle duplicates
The solution depends on the business requirements and on the way we want to handle these duplicates. Handling duplicates when processing the CVS would mean we need to somehow store
row data while processing the entire file. This would also cause high memory usage

#### Solution
As a solution to the above problems, I decided to go with using the `Flow` library. Flow enables the creation of data pipelines while leveraging concurrency. The main steps taken are as follows:
 - Create a data stream from the file
 - concurrently parse the rows
 - Create a partition (batch) on the data stream while we aggregate valid/invalid rows
 - Each time we have the partition, insert the valid rows in the database (basically we are inserting batches)
 - Once we are done, merge the flows/streams
 - aggregate the results across all flows and have a final valid/invalid rows structure

By default, Flow will try to use the full extent of number of CPUs when parallelizing tasks.   

The result will be a map like this:

    %{
	    valid: %{
		    count: 3111113,
		    rows: []
	    },
	    invalid: %{
		    count: 100,
		    rows: [%{}, %{}]
	    }
    {
   
 
I decided to return the full invalid row to make it easier to identify and fix the problem in the CVS. Of course, if the number of invalid rows is very high, we will just return some partial data to preserve memory.

A crude diagram of the flow:
[Import Flow diagram](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=Untitled.drawio#R7Vxbc5s4FP4t%2b5CZ9sEZkLjYj2nSbndmd6bTzGzbRwUUrAYjr5CTeH/9SiBskOyEUIKUbPxidCSEOPp0vnN04QSer%2b5/Z2i9/IumOD8BXnp/Ai9OAPABDMSflGyVxAdhLckYSZVsL7gk/2Il9JR0Q1JcdgpySnNO1l1hQosCJ7wjQ4zRu26xa5p3n7pGGTYElwnKTek3kvJlLZ2H3l7%2bGZNs2TzZ91TOCjWFlaBcopTetUTw4wk8Z5Ty%2bmp1f45zqb1GL/V9n47k7hrGcMH73PDH7Pp7yc6WN9%2b9y684%2bfaT0p8zf6Eax7fNG%2bNUKEAlKeNLmtEC5R/30g%2bMbooUy2o9kdqX%2bZPStRD6QvgTc75VvYk2nArRkq9ylStazLbf5f2nYZP8oaqrEhf3ndRWpeq2ygYe1YESlXTDEvzAiwOFJcQyzB9SULjrKgFyTFdYNEjcyHCOOLntNgQpsGW7cvv%2bEBeqS57QPaqVtyjfqCet0FoI3olXLrGoUuSQFHH83ujGfSdJjd8tCceXa1Tp5E6M1W6HqMdgxvH9w6o1NbEb6wrnaqTDSKXv9sNmV2bZGjJNudGVFxnKM7FepGfSSIhUkqOyJElXL12kt2AbBaAD3FMPwkfAW6W%2bYEbE22E2PqJ92BPS4HA/tvopPNBNjaw38NUTvlAi3mQHExh0YeLPte6v31Pd1TZnekULrSKoVVTrwaiogtLutYejKz6ArigXyvogakaSkZZyjNbai/7ZSDP/YcOvZ/N9Ulxl6r%2b6s1yjogPQpmBCcyogcyb1n129A1KJotle%2b%2bJ9VZFguILPrtGK5Nv6hs84v8WcJKiVX1aWWeb6YH3fzqgfLXMKylYob%2bXdIkaQ%2bM9JhviGSVZ%2bsFyC1seK3ClgyczAqweClwvOwGwmlJCQIjPvpGy9RIWqEtQyYa/4TNjArKjFiRg2cnDt8ogYv4V6kte8apXDmajsWtTfPKnAda4YCJXb0HrMHWVpt2G7usS7XN0QUZ2ss%2bSM3uCZGkqdclcouckqezLTelOYkqoPYVz/B/H7VjNTnFAmRhwtZnxJkpsCl6ptpCCcNMrRy7Y68sFyrbZ0yl3nFHFdMykp1znaNsVzIjKA9xtZrYUTgAoFZQ3cxxmrBr2Q1bhvxoJlIosC14hs/qqI7FF%2bip9EeNaILNT4ZzGQyAJPqyiYlsgWb0T2RmRvRPb6iAx6rhFZM6nzf2GyZnLFcSaLujgB3lAm8zUmC6dlMt9/o7I3KnujstdHZUHsHJWZU7Ovmsr8p01D2uKyWKOg3TrSU7ks1kjR15H03FwGDXxdoIrDhD3DaNWM1CvmzCCF8yOBrL1BGhpKFK/DibSy0vxvKw7gyVIqTtKvbRXqiyjBwroKzVUUt1WoRz0OqNBcKnBbhTrbOqBCcwrUbRXqk8j2VQgOBUe/5LCc9PYuxluNjw5rfRrnItSmfKOhgXKk2ahw4kC56fqXjYXYJhYABN0Bri8/917HBvMuFnRQPTcWTEfTHSws%2bmLhyC6dibAQiAit/YOdHo0Hm4kInnpBt6754hT6IBYmJJoDGITTYiVwGCu97cbcKlZA3LUbzfB/Mjg0MgobN3MqLJixlTtY6G03rPoTuukfzCE6GU3OIaNvtbOBBav%2bBNRjrsH%2bhFbR5Fg4tDHuxWHBKkcE3mIcLISebxcLo%2b9c6o8Fx33GUJ8gaPzwX/YDvIn9gEP7h1wZ735vMDg1sRDAgWAAhlMYTAqGxlCNuCp2T3i9KBbUa2Ai/UOVlNf75TCZ2LYSz7nVvjesrPoUuvkfzCM6IU3NI9Dlucv%2bYLDqVIRjTViF0O6EVXOk0EkwxH2xYNf5iEdyMKPYroMJXZ6E6I0Fq76H7j8GvjanONz3mHZyErocePbGglWHwcDC0KBkZ1AsBSXQYuA5Hhas%2bgu6aR/uL8SWnUczQP2K000it0nOarm4H3wihbryqq8GiPYVMsGFbtmJ/MDARrXPpQ1CkfU9VsEzhnxh74BvxOHZ0Naj47MGlitzBi92M0JgBncvd3zqu88cGJ/gFalX35nmgHrN7RMvV736rjUH1Dt6sP%2bc7GJt8TBcnIYPG/Hey4dGVdHE55GD8b/b8gq7PASjdblZ1eRd7nLobjkMWxj9rBvb3kdajvkmU/WyGZT/XR88q3dx14x4IQ%2b1kaIUPCYucrTFzMCCPDDX7f36kN95fXDuQp2OuyZ5ronUscSL3ZlEyZckQfmZyliRNK0%2bcnaIbQ9h7NfCOa1HwtDg2%2bgAtvRQfDy6NWPlsyxjOEMcV1guNzkvjf6wfdJoDmz7Kc1ofw7Siq2Ewc20yaNhcGA1DNaHUDz0e2JAO/AXT/w9sdDlNc4mRnccDFCbdo6Hnv7c7ZtoDMzUYHB5U34zo%2bA4GIAOBjAQDIEOhon9ptDlBe%2bg71cn7YIhBF0nerBlCKJuReNZBpHcfwy4Lr7/pjL8%2bB8=)

### Improvements to the flow
There are a couple of improvements that can be made to the entire flow
* Improve insert in the DB - create the insert commands by hand to avoid postgres parameter limit of 65k and therefore increase the batch size
* Use a more specialized tool for timing the whole operation (maybe Banchee) rather than :timer.tc
* Improve the validation. Right now I used an `embedded_schema` to validate the CVS entry. I still need to add the actual data type validations

As performance goes, the 1 mil line file was processed (parsed/validated) in under 2 sec (no DB interaction). Adding a 4 GB PostgreSQL server increased the time to about 70 sec. 
#### Data Model
To keep things simple, there is no additional data model besides the DB schema. If we would have different business logic which would require a more complex model, we can add this additional layer.

Also, I modeled all fields as strings. As an improvement, we can model the latitude/longitude using specific geo-spatial data types (we can use PostGIS extension for Postgres for example).

### API
I went with using a simple Phoenix app that exposes the geolocation data. Due to lack of time, I haven't packaged the importer and geolocation data retriever in a separate app and just used the out-of-the-box Phoenix application. Of course, the importer is in his own module, and refactoring the whole app to have a clearer separation between the data producer and consumers shouldn't be an issue
####  Improvements to API
* Better parameter validation
* rate limiter


#### Deployment:
The application can be accessed
API specs:
https://geo-location-vio.gigalixirapp.com/doc
usage:
* https://geo-location-vio.gigalixirapp.com/api/123 - `400`
* https://geo-location-vio.gigalixirapp.com/api/138.13.94.101 - `404`
* https://geo-location-vio.gigalixirapp.com/api/138.13.94.100 - `200`

#### Setup
Prerequirements:
`Postgresql, Elixir, Erlang`

`clone repo`
`run mix setup`

Start Phoenix endpoint with mix phx.server or inside IEx with `iex -S mix phx.server`
Now you can visit localhost:4000 from your browser.
Once the server is up and running, you can use `localhost:4000/doc#` to access the Swagger API doc. This will also provide a way to directly test the endpoint

Run in docker
`clone repo`
`docker-compose up`

Running tests
`run MIX_ENV=test mix test`
or
`docker-compose run --rm -e "MIX_ENV=test"  -e "PGDATABASE=geo_location_test" app mix do deps.get, compile --warnings-as-errors, test`git 
