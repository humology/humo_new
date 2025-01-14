defmodule Mix.Tasks.Humo.New.Config do
  use Mix.Task

  require Mix.Generator

  Mix.Generator.embed_template(:config, """
  import Config

  config :humo, Humo,
    apps: [<%= if @apps != [] do %>
      <%= Enum.map(@apps, &inspect(&1)) |> Enum.join(",\n    ") %>
    <% end %>],
    otp_app: <%= inspect(@otp_app) %><%= for %{path: path} <- @apps do %>
  <% config_path = normalize(["../", path, "config/plugin.exs"]) %>
  if Path.expand(<%= inspect(config_path) %>, __DIR__) |> File.exists?(),
    do: import_config(<%= inspect(config_path) %>)<% end %>
  """)

  @impl true
  def run(_args) do
    Mix.shell().info("Running task humo.new.config")

    environments = [:test, :dev, :prod]

    for env <- environments do
      {otp_app, apps} = ordered_apps(env)
      res = config_template(otp_app: otp_app, apps: apps)

      Mix.Generator.create_file("config/humo_#{env}.exs", res, force: true)
    end
  end

  defp ordered_apps(env) do
    mix_project = get_mix_project("./")
    otp_app = Keyword.fetch!(mix_project, :app)
    otp_deps_path = Keyword.get(mix_project, :deps_path, "deps")

    apps =
      Stream.resource(
        fn -> {collect_apps_deps({otp_app, "./"}, env, otp_deps_path), MapSet.new()} end,
        fn {apps_deps, known_apps} ->
          unlocked_apps =
            for {app, deps} <- apps_deps, MapSet.subset?(deps, known_apps) do
              app
            end

          case {unlocked_apps, apps_deps} do
            {[], []} ->
              {:halt, known_apps}

            {[], _} ->
              raise ArgumentError, "Circular dependency"

            _ ->
              new_apps_deps =
                for {app, deps} <- apps_deps, app not in unlocked_apps do
                  {app, deps}
                end

              new_known_apps = MapSet.new(unlocked_apps) |> MapSet.union(known_apps)

              {unlocked_apps, {new_apps_deps, new_known_apps}}
          end
        end,
        fn _known_apps -> :ok end
      )
      |> Enum.to_list()
      |> Enum.filter(fn {_app, path} -> is_humo_plugin?(path) end)
      |> Enum.map(fn {app, path} -> %{app: app, path: path} end)

    {otp_app, apps}
  end

  defp collect_apps_deps(otp_app, env, otp_deps_path) do
    Stream.resource(
      fn -> {[otp_app], MapSet.new()} end,
      fn
        {[app | rest], known_apps} ->
          deps = get_app_deps(app, env, otp_deps_path)
          unknown_apps = Enum.reject(deps, &(&1 in known_apps))
          new_known_apps = MapSet.new([app | unknown_apps]) |> MapSet.union(known_apps)
          {[{app, MapSet.new(deps)}], {unknown_apps ++ rest, new_known_apps}}

        {[], known_apps} ->
          {:halt, known_apps}
      end,
      fn _known_apps -> :ok end
    )
    |> Enum.to_list()
  end

  defp get_app_deps({_app, path}, env, otp_deps_path) do
    if Path.join(path, "mix.exs") |> File.exists?() do
      get_deps_paths_from_mix(path, env, otp_deps_path)
    else
      # ignore dependencies without mix.exs
      []
    end
  end

  defp is_humo_plugin?(app_path) do
    if Path.join(app_path, "mix.exs") |> File.exists?() do
      get_mix_project(app_path)
      |> Keyword.get(:humo_plugin, false)
    else
      # ignore dependencies without mix.exs
      false
    end
  end

  defp get_deps_paths_from_mix(app_path, env, otp_deps_path) do
    get_mix_project(app_path)
    |> Keyword.get(:deps, [])
    |> Enum.map(fn
      {app, version} when is_binary(version) -> {app, []}
      {app, opts} when is_list(opts) -> {app, opts}
      {app, _version, opts} -> {app, opts}
    end)
    |> Enum.filter(fn {_app, opts} ->
      env in List.wrap(Keyword.get(opts, :only, env))
    end)
    |> Enum.map(fn {app, opts} ->
      case Keyword.get(opts, :path) do
        nil ->
          {app, Path.join(otp_deps_path, "#{app}")}

        dep_path ->
          {app, normalize([app_path, dep_path])}
      end
    end)
    |> MapSet.new()
  end

  defp get_mix_project(app_path) do
    File.cd!(app_path, fn ->
      mix_module = get_module_from_mix("mix.exs")

      unless function_exported?(mix_module, :project, 0) do
        Code.compile_file("mix.exs")
      end

      mix_module.project()
    end)
  end

  defp get_module_from_mix(mix_path) do
    {:defmodule, _, [{:__aliases__, _, module_list} | _]} =
      mix_path
      |> File.read!()
      |> Code.string_to_quoted!()

    Module.concat(module_list)
  end

  defp normalize(paths) when is_list(paths) do
    Path.join(paths)
    |> Path.split()
    |> do_normalize([])
    |> Path.join()
  end

  defp do_normalize([], acc), do: Enum.reverse(acc)

  defp do_normalize(["." | rest], acc) do
    do_normalize(rest, acc)
  end

  defp do_normalize([".." | rest], [last | acc]) when last != ".." do
    do_normalize(rest, acc)
  end

  defp do_normalize([item | rest], acc) do
    do_normalize(rest, [item | acc])
  end
end
