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

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end

  def fetch(key, default_value_function) do
    case get(key) do
      {:not_found} -> set(key, default_value_function.())
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

  def keys() do
    GenServer.call(__MODULE__, {:get_all_keys})
  end

  # GenServer callbacks

  def handle_call({:get, key}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.lookup(ets_table_name, key)
    {:reply, result, state}
  end

  def handle_call({:set, key, value}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    true = :ets.insert(ets_table_name, {key, value})
    {:reply, value, state}
  end

  def handle_call({:get_all_keys}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.foldl(fn({key, val}, acc) ->
      [key] ++ acc end, [], ets_table_name)
    {:reply, result, state}
  end

end
