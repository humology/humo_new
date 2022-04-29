defmodule Mix.Tasks.Local.Humo do
  use Mix.Task

  @shortdoc "Updates the Humo project generator locally"

  @moduledoc """
  Updates the Humo project generator locally.

      $ mix local.humo

  Accepts the same command line options as `archive.install hex humo_new`.
  """

  @impl true
  def run(args) do
    Mix.Task.run("archive.install", ["hex", "humo_new" | args])
  end
end
