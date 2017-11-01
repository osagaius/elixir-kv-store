defmodule ElixirKvStore.StoreTest do
  use ElixirKvStore.ConnCase
  require Logger

  setup do
    ElixirKvStore.Store.clear()
    :ok
  end

  test "set key with value" do
    key = "test_key1"
    val = "test_val"
    ElixirKvStore.Store.set(key, val)
    assert ElixirKvStore.Store.fetch(key) == val
  end

  test "set key with value and expiration" do
    ElixirKvStore.Store.clear()
    key = "test_key1"
    val = "test_val"
    ElixirKvStore.Store.set(key, val, 10)
    assert ElixirKvStore.Store.fetch(key) == val
    state = ElixirKvStore.Store |> Process.whereis |> :sys.get_state
    :timer.sleep(5)
    assert Process.read_timer(state.timer_refs[key]) < 10
    :timer.sleep(20)
    assert ElixirKvStore.Store.fetch(key) == nil
  end

end
