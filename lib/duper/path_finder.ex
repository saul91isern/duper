defmodule Duper.PathFinder do
  @moduledoc """
  Depth first search on our filesystem starting from a provided root path..
  """
  use GenServer

  @module __MODULE__

  @doc """
  Starts a GenServer process and links it to the current process.

  This is often used to start the GenServer as part of a supervision tree.
  """
  def start_link(root) do
    GenServer.start_link(__MODULE__, root, name: @module)
  end

  @doc """
  Invoked when the server is started. start_link/3 or start/3 will block until it returns.

  We will start the `DirWalker` process, and add it to the state.
  """
  @impl GenServer
  def init(path) do
    DirWalker.start_link(path)
  end

  @doc """
  Gets next path to process in our file system.

  Returns `path`.

  ## Examples

  iex> Duper.PathFinder.next_path()
  "/path/foo/bar"
  """
  def next_path do
    GenServer.call(@module, :next_path)
  end

  @impl GenServer
  def handle_call(:next_path, _from, walker_process) do
    path =
      case DirWalker.next(walker_process) do
        [path] -> path
        path -> path
      end

    {:reply, path, walker_process}
  end
end
