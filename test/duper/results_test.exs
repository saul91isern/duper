defmodule Duper.ResultsTest do
  alias Duper.Results
  use ExUnit.Case

  test "adds entries to the results" do
    Results.add_hash_for_path("path1", 123)
    Results.add_hash_for_path("path2", 456)
    Results.add_hash_for_path("path3", 123)
    Results.add_hash_for_path("path4", 789)
    Results.add_hash_for_path("path5", 456)

    duplicates = Results.find_duplicates()
    ~w(path1 path3) in duplicates
    ~w(path2 path5) in duplicates
  end
end
