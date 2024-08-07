defmodule Duper.Results do
  @moduledoc """
  Wraps and Elixir map. The default state is an empty map. The keys will
  be the file hashes and the values will be the file paths in our file system.
  """

  use GenServer

  @module __MODULE__
  @default_state %{}

  @doc """
  Starts a GenServer process and links it to the current process.

  This is often used to start the GenServer as part of a supervision tree.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @module)
  end

  @doc """
  Invoked when the server is started. start_link/3 or start/3 will block until it returns.
  """
  @impl GenServer
  def init(_no_args) do
    {:ok, @default_state}
  end

  @doc """
  Adds a hash for a path of our filesystem. If the hash already exists,
  we will add a new path under the existing hash.

  This is handled asynchronously through a GenServer.cast/2

  Returns `:ok`.

  ## Examples

    iex> Duper.Results.add_hash_for_path("/Users/user/Documents/projects/duper", "hash")
    :ok
  """
  @spec add_hash_for_path(path :: binary(), hash :: binary()) :: :ok
  def add_hash_for_path(path, hash) do
    GenServer.cast(@module, {:add, path, hash})
  end

  @doc """
  Finds all duplicated files in our filesystem.

  Returns []

  ## Examples
    iex> Duper.Results.find_duplicates()
    ["/Users/user/Documents/projects/duper"]
  """
  @spec find_duplicates() :: list(binary())
  def find_duplicates() do
    GenServer.call(@module, :find_duplicates)
  end

  @impl GenServer
  def handle_cast({:add, path, hash}, results) do
    results = Map.update(results, hash, [path], fn existing -> [path | existing] end)
    {:noreply, results}
  end

  @impl GenServer
  def handle_call(:find_duplicates, _from, results) do
    {:reply, hashes_with_more_than_one_path(results), results}
  end

  defp hashes_with_more_than_one_path(results) do
    results
    |> Enum.filter(fn {_hash, paths} -> length(paths) > 1 end)
    |> Enum.map(&elem(&1, 1))
  end
end
