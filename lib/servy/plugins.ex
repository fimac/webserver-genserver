defmodule Servy.Plugins do
  alias Servy.Conv
  require Logger
  @doc "Logs 404 requests"
  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn("warning: #{path} is on the loose")
    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(conv), do: conv

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(%Conv{} = conv), do: IO.inspect(conv)
end
