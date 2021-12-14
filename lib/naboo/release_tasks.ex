defmodule Naboo.ReleaseTasks do
  alias Ecto.Migrator

  @app :naboo

  def migrate do
    IO.puts("Running migrations for #{@app}")

    for repo <- repos() do
      {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :up, all: true))
    end

    if File.exists?("./seeds.exs") do
      Code.eval_file("./seeds.exs")
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
