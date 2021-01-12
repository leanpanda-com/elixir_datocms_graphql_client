defmodule DatoCMS.Test.Support.FixtureHelper do
  def fixtures_path, do: Path.join("test", "fixtures")

  def read_fixture(filename) do
    Path.join(fixtures_path(), filename)
    |> File.read!
  end

  def json_fixture!(name) do
    {:ok, data} =
      read_fixture(name <> ".json")
      |> Jason.decode(keys: :atoms)

    data
  end
end
