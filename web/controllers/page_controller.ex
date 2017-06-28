defmodule ElixirKvStore.PageController do
  use ElixirKvStore.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
