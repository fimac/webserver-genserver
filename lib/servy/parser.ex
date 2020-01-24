defmodule Servy.Parser do
  # This transforms the request string into a key value pair (map)
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _version] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  def parse_headers([], headers), do: headers

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")

    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
    # because the last thing the function does is call itself
    # Elixir uses tail call optimisation, no new frames are pushed onto the call stack, so it consumes no additional memory
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
