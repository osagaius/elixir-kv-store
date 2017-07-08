defmodule ElixirKvStore.KVController do
  use ElixirKvStore.Web, :controller
  alias ElixirKvStore.Store
  require Logger

  def index(conn, _params) do
    keys = Store.keys()
    json conn, keys
  end

  def get(conn, params=%{"key" => key}) do
    result = Store.fetch(key)
    json conn, result
  end

  def get_ttl(conn, params=%{"key" => key}) do
    result = Store.get_ttl(key)
    json conn, result
  end

  def add(conn, params=%{"key" => key, "value" => value, "expiration" => exp}) do
    result = case exp |> Integer.parse do
      {number, _} -> Store.set(key, value, number)
      _ -> Store.set(key, value)
    end

    json conn, result
  end

  def add(conn, params=%{"key" => key, "value" => value}) do
    result = Store.set(key, value)
    json conn, result
  end

  def delete(conn, params=%{"key" => key}) do
    result = Store.delete(key)
    json conn, result
  end
end
