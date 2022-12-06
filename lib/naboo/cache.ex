defmodule Naboo.Cache do
  use GenServer

  @moduledoc """
    This is just a little cache implemented as a GenServer.
    It is mainly meant for TOTP tokens, but such an implementation could be used for other
    things as well.

    {:ok, pid} = Cache.start_link()

    # Store something in the cache
    Cache.put(pid, :foo, 123)
    #=> :ok

    # Get the stored value:
    Cache.get(pid, :foo)
    #=> 123

    # Wait more than 10 seconds, then try again:
    Cache.get(pid, :foo)
    #=> nil
  """

  def start_link(options \\ []) do
    {name, options} = Keyword.pop(options, :name, __MODULE__)
    GenServer.start_link(__MODULE__, options, name: name)
  end

  def del(pid, key) do
    GenServer.call(pid, {:del, key})
  end

  # Put in cache for 120 seconds
  def put(pid, key, value, ttl \\ 120_000) do
    GenServer.call(pid, {:put, key, value, ttl})
  end

  def from_value(pid, key) do
    GenServer.call(pid, {:from_value, key})
  end

  def clear(pid), do: GenServer.call(pid, {:clear})

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(_) do
    state = %{}
    {:ok, state}
  end

  def handle_call({:clear}, _from, _state) do
    {:reply, Map.new()}
  end

  def handle_call({:from_value, value}, _from, state) do
    value =
      state
      |> Enum.find(fn {_key, val} -> val == value end)
      |> elem(0)

    {:reply, value, state}
  end

  def handle_call({:del, key}, _from, state) do
    {:reply, Map.delete(state, key)}
  end

  def handle_call({:put, key, value, ttl}, _from, state) do
    Process.send_after(self(), {:expire, key}, ttl)
    {:reply, :ok, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_info({:expire, key}, state) do
    {:noreply, Map.delete(state, key)}
  end
end
