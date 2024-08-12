defmodule Duper.Worker do
  @doc """
  The worker. Collects next available file in the system, hashes it,
  and stores the result in the gatherer.
  """
  use GenServer, restart: :transient

  alias Duper.Gatherer
  alias Duper.PathFinder

  @doc """
  Start worker from the dynamic supervisor. Because it will
  be triggered dynamically, we won't specify a name.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Starts the process by processing one file.
  """
  @impl GenServer
  def init([]) do
    {:ok, nil, {:continue, nil}}
  end

  @impl GenServer
  def handle_continue(_continue_arg, _state) do
    process_file()
  end

  @doc """
  Process one file at a time, until the the finder returns
  a nil path, which means that there are no more files to process.
  """
  @impl GenServer
  def handle_info(:process_file, _state) do
    process_file()
  end

  defp process_file do
    process(PathFinder.next_path())
  end

  defp process(nil) do
    Gatherer.done()
    {:stop, :normal, nil}
  end

  defp process(path) do
    hash = hash_file(path)
    Gatherer.add_result(path, hash)
    send(self(), :process_file)
    {:noreply, nil}
  end

  defp hash_file(path) do
    path
    |> File.stream!(1024 * 1024)
    |> Enum.reduce(:crypto.hash_init(:md5), fn block, hash ->
      :crypto.hash_update(hash, block)
    end)
    |> :crypto.hash_final()
  end
end
