defmodule GeoLocationWeb.Validator do
  # naive validation of ip address
  @ip_regex ~r/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
  @ip_values ~w(ip)a

  def validate(value, field) when is_binary(value) and field in @ip_values do
    case Regex.match?(@ip_regex, value) do
      true -> {:ok, value}
      false -> {:error, "Invalid IP address"}
    end
  end
end
