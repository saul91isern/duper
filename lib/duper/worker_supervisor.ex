defmodule Duper.WorkerSupervisor do
  use DynamicSupervisor

  @module WorkerSupervisor

  @doc """
  Starts a DynamicSupervisor process and links it to the current process.

  Starts the DynamicSupervisor as part of a supervision tree.
  """
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: @module)
  end

  @doc """
  Invoked when the server is started. start_link/3 or start/3 will block until it returns.

  We will start the supervisor with a `one_for_one` strategy.
  """
  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Adds a new worker dynamically to the supervision tree.
  """
  def add_worker do
    {:ok, _pid} = DynamicSupervisor.start_child(@module, Duper.Worker)
  end
end
