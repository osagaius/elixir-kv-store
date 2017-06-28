defmodule ElixirKvStore.KVController do
  use ElixirKvStore.Web, :controller
  alias ElixirKvStore.Store

  def index(conn, _params) do
    keys = Store.keys()
    json conn, keys
  end
end
