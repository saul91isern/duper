defmodule Duper.Gatherer do
  use GenServer

  @module Gatherer

  @doc """
  Starts a GenServer process and links it to the current process.

  The process will be initialized with the worker count.
  """
  def start_link(worker_count) do
    GenServer.start_link(__MODULE__, worker_count, name: @module)
  end

  @doc """
  The default state is the number of Duper.Worker that will process
  the file system
  """
  @impl GenServer
  def init(worker_count) do
    {:ok, worker_count, {:continue, worker_count}}
  end

  @doc """
  When a worker is done executing, we will substract one worker to the count. If the worker
  finishing is the last one, we will halt the erlang system and print the duplicate files.
  """
  def done do
    GenServer.cast(@module, :done)
  end

  @doc """
  Stores the path under the given hash of the file.
  """
  def add_result(path, hash) do
    GenServer.cast(@module, {:add_result, path, hash})
  end

  @impl GenServer
  def handle_continue(worker_count, state) do
    Enum.each(1..worker_count, fn _ -> Duper.WorkerSupervisor.add_worker() end)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:done, 1) do
    IO.puts("Results:\n")
    Enum.each(Duper.Results.find_duplicates(), &IO.inspect/1)
    {:noreply, System.halt()}
  end

  @impl GenServer
  def handle_cast(:done, worker_count) do
    {:ok, worker_count - 1}
  end

  @impl GenServer
  def handle_cast({:add_result, path, hash}, worker_count) do
    :ok = Duper.Results.add_hash_for_path(path, hash)
    {:noreply, worker_count}
  end
end
