defmodule Mix.Tasks.Humo.New.Web do
  @moduledoc """
  Creates a new Phoenix web project within an umbrella project.

  It expects the name of the OTP app as the first argument and
  for the command to be run inside your umbrella application's
  apps directory:

      $ cd my_umbrella/apps
      $ mix humo.new.web APP [--module MODULE] [--app APP]

  This task is intended to create a bare Phoenix project without
  database integration, which interfaces with your greater
  umbrella application(s).

  ## Examples

      $ mix humo.new.web hello_web

  Is equivalent to:

      $ mix humo.new.web hello_web --module HelloWeb

  Supports the same options as the `humo.new` task.
  See `Mix.Tasks.Humo.New` for details.
  """

  @shortdoc "Creates a new Phoenix web project within an umbrella project"

  use Mix.Task

  @impl true
  def run([]) do
    Mix.Tasks.Help.run(["humo.new.web"])
  end

  def run([path | _] = args) do
    unless HumoNew.Generator.in_umbrella?(path) do
      Mix.raise "The web task can only be run within an umbrella's apps directory"
    end

    Mix.Tasks.Humo.New.run(args, HumoNew.Web, :web_path)
  end
end
