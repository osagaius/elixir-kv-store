defmodule ElixirKvStore.Store do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    Logger.debug("starting #{inspect __MODULE__}")
    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :store_table},
      {:log_limit, 1_000_000}
    ], [name: __MODULE__])
  end

  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name, timer_refs: %{}}}
  end

  def fetch(key) do
    case get(key) do
      {:not_found} -> nil
      {:found, result} -> result
    end
  end

  def get(key) do
    case GenServer.call(__MODULE__, {:get, key}) do
      [] -> {:not_found}
      [{_key, result}] -> {:found, result}
    end
  end

  def set(key, value) do
    GenServer.call(__MODULE__, {:set, key, value})
  end

  def set(key, value, expiration) do
    GenServer.call(__MODULE__, {:set, key, value, expiration})
  end

  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  def keys() do
    GenServer.call(__MODULE__, {:get_all_keys})
  end

  def clear() do
    GenServer.call(__MODULE__, {:clear})
  end

  def get_ttl(key) do
    GenServer.call(__MODULE__, {:get_ttl, key})
  end

  # GenServer callbacks

  def handle_call({:get, key}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.lookup(ets_table_name, key)
    {:reply, result, state}
  end

  def handle_call({:delete, key}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.delete(ets_table_name, key)
    {:reply, result, state}
  end

  def handle_call({:set, key, value}, _from, state) do
    %{ets_table_name: ets_table_name} = state

    cancel_timer(key, state)

    true = :ets.insert(ets_table_name, {key, value})
    {:reply, value, state}
  end

  def handle_call({:set, key, value, expiration}, _from, state) do
    %{ets_table_name: ets_table_name} = state

    cancel_timer(key, state)

    timer_ref = Process.send_after(__MODULE__, {:delete, key}, expiration)

    new_timer_refs = state
    |> Map.get(:timer_refs)
    |> Map.put(key, timer_ref)

    state = state |> Map.put(:timer_refs, new_timer_refs)

    true = :ets.insert(ets_table_name, {key, value})
    {:reply, value, state}
  end

  def handle_call({:get_all_keys}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.foldl(fn({key, val}, acc) ->
      [key] ++ acc end, [], ets_table_name)
    {:reply, result, state}
  end

  def handle_call({:clear}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.delete_all_objects(ets_table_name)
    {:reply, result, state}
  end

  def handle_call({:get_ttl, key}, _from, state) do
    result = Process.read_timer(state.timer_refs[key])
    {:reply, result, state}
  end

  def handle_info({:delete, key}, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.delete(ets_table_name, key)
    {:noreply, result, state}
  end

  defp cancel_timer(key, state) do
    case timer_ref = state.timer_refs[key] do
      nil -> nil
      _ -> Process.cancel_timer(timer_ref)
    end
  end
end
