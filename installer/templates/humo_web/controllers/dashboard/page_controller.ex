defmodule <%= @web_namespace %>.Dashboard.PageController do
  use <%= @web_namespace %>, :controller

  def index(conn, _params) do
    render(conn, "index.html", page_title: "Overview")
  end
end
