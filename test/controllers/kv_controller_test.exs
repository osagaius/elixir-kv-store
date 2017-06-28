defmodule ElixirKvStore.KVControllerTest do
  use ElixirKvStore.ConnCase
  require Logger

  test "GET /api/", %{conn: conn} do
    ElixirKvStore.Store.set("test_key", "test_val")

    conn = get conn, "/api/"
    assert json_response(conn, 200) == ["test_key"]
  end
end
