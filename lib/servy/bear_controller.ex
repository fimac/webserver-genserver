defmodule Servy.BearController do
  alias Servy.Wildthings

  def index(conv) do
    bears = Wildthings.list_bears()
    # TODO: Transform into an HTML list
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def show(conv, %{"id" => id}) do
    %{conv | status: 200, resp_body: "Bears #{id}"}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear name #{name}"
    }
  end
end
