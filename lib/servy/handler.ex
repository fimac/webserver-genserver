defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests
  """
  alias Servy.BearController
  alias Servy.Conv
  alias Servy.FileHandler
  alias Servy.Parser
  alias Servy.Plugins

  @pages_path Path.expand("pages", File.cwd!())

  @doc "Transforms the request into a response"
  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> Plugins.log()
    |> route
    |> Plugins.track()
    |> format_response
  end

  # Transforms the parsed map, into a new map with a response body
  def route(%Conv{path: "/wildthings", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{path: "/bears", method: "GET"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{path: "/bears", method: "POST"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{path: "/about", method: "GET"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{path: "/bears/new", method: "GET"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{path: "/bears/" <> id, method: "GET"} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{path: "/bears/" <> id, method: "DELETE"} = conv) do
    %{conv | status: 403, resp_body: "Deleting #{id} bear is not allowed."}
  end

  def route(%Conv{} = conv) do
    %{conv | status: 404, resp_body: "No #{conv.path} here!"}
  end

  # Takes the final map, transforms into a valid http response string.
  def format_response(%Conv{} = conv) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# First line: method/the path/the http protocol
# Second: List of headers, key value pairs.
# Host: resource being requested
# User-Agent: the software making the request
# Accept: The media types accepted in the response, this is set as a wildcard
# There is a blank line, which is where the body would go, we will see this in a post request.

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """

# The response we want to send back
# Status: the http version, the status code, reason phrase
# Response headers
# Content-Type: media type for the body
# Content-Length: size of the body
# Blank link to seperate the body
response = Servy.Handler.handle(request)
IO.puts(response)

request_two = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_two = Servy.Handler.handle(request_two)
IO.puts(response_two)

request_three = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_three = Servy.Handler.handle(request_three)
IO.puts(response_three)

request_four = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_four = Servy.Handler.handle(request_four)
IO.puts(response_four)

request_five = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_five = Servy.Handler.handle(request_five)
IO.puts(response_five)

request_six = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_six = Servy.Handler.handle(request_six)
IO.puts(response_six)

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)
IO.puts(response)
