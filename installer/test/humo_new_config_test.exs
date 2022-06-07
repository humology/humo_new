Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Humo.New.ConfigTest do
  use ExUnit.Case

  import MixHelper

  setup_all do
    # Get Mix output sent to the current
    # process to avoid polluting tests.
    Mix.shell(Mix.Shell.Process)
  end

  test "create configs based on mix project files" do
    in_tmp("mix_humo_new_config", fn ->
      write_mix("deps/core", [app: :core, humo_plugin: true])
      write_mix("deps/users", [app: :users, humo_plugin: true], [{:core, "~> 1"}])
      write_mix("", [app: :my_app, humo_plugin: true], [{:users, "~> 1"}])

      Mix.Tasks.Humo.New.Config.run([])

      assert_received {:mix_shell, :info, ["Running task humo.new.config"]}
      assert_received {:mix_shell, :info, ["* creating config/humo_test.exs"]}
      assert_received {:mix_shell, :info, ["* creating config/humo_dev.exs"]}
      assert_received {:mix_shell, :info, ["* creating config/humo_prod.exs"]}

      expected_config =
        """
        import Config

        config :humo, Humo,
          apps: [
            %{app: :core, path: "deps/core"},
            %{app: :users, path: "deps/users"},
            %{app: :my_app, path: "./"}
          ],
          server_app: :my_app

        if Path.expand("../deps/core/config/plugin.exs", __DIR__) |> File.exists?(),
          do: import_config "../deps/core/config/plugin.exs"

        if Path.expand("../deps/users/config/plugin.exs", __DIR__) |> File.exists?(),
          do: import_config "../deps/users/config/plugin.exs"

        if Path.expand("../config/plugin.exs", __DIR__) |> File.exists?(),
          do: import_config "../config/plugin.exs"
        """

      assert_file "config/humo_test.exs", expected_config
      assert_file "config/humo_dev.exs", expected_config
      assert_file "config/humo_prod.exs", expected_config
    end)
  end

  test "when dependency is only for env, it will appear only in that env config" do
    for only <- [:test, :dev, :prod, [:test, :dev], [:dev, :prod]] do
      in_tmp("mix_humo_new_config", fn ->
        write_mix("deps/debug", [app: :debug, humo_plugin: true])
        write_mix("", [app: :my_app, humo_plugin: true], [{:debug, "~> 1", only: only}])

        Mix.Tasks.Humo.New.Config.run([])

        debug_apps_item = "%{app: :debug, path: \"deps/debug\"}"
        debug_import_config =
          """
          if Path.expand("../deps/debug/config/plugin.exs", __DIR__) |> File.exists?(),
            do: import_config "../deps/debug/config/plugin.exs"
          """

        for env <- [:test, :dev, :prod] do
          file_content = File.read!("config/humo_#{env}.exs")
          if env in List.wrap(only) do
            assert file_content =~ debug_apps_item
            assert file_content =~ debug_import_config
          else
            refute file_content =~ debug_apps_item
            refute file_content =~ debug_import_config
          end
          assert file_content =~ "my_app"
        end
      end)
    end
  end

  test "dependency without mix.exs ignored" do
    in_tmp("mix_humo_new_config", fn ->
      write_mix("deps/users", [app: :users, humo_plugin: true], [{:core, "~> 1"}])
      write_mix("", [app: :my_app, humo_plugin: true], [{:users, "~> 1"}])

      Mix.Tasks.Humo.New.Config.run([])

      for env <- [:test, :dev, :prod] do
        file_content = File.read!("config/humo_#{env}.exs")
        refute file_content =~ "core"
        assert file_content =~ "my_app"
      end
    end)
  end

  test "when dependency humo_plugin is not true, it's ignored" do
    in_tmp("mix_humo_new_config", fn ->
      write_mix("deps/core", [app: :core, humo_plugin: false])
      write_mix("deps/debug", [app: :debug, humo_plugin: true])
      write_mix("deps/users", [app: :users], [{:core, "~> 1"}, {:debug, "~> 1"}])
      write_mix("", [app: :my_app, humo_plugin: true], [{:users, "~> 1"}])

      Mix.Tasks.Humo.New.Config.run([])

      for env <- [:test, :dev, :prod] do
        file_content = File.read!("config/humo_#{env}.exs")
        refute file_content =~ "core"
        refute file_content =~ "debug"
        refute file_content =~ "users"
        assert file_content =~ "my_app"
      end
    end)
  end

  test "circular dependency error" do
    in_tmp("mix_humo_new_config", fn ->
      write_mix("deps/core", [app: :core, humo_plugin: true], [{:users, "~> 1"}])
      write_mix("deps/users", [app: :users, humo_plugin: true], [{:core, "~> 1"}])
      write_mix("", [app: :my_app, humo_plugin: true], [{:users, "~> 1"}])

      assert_raise ArgumentError, "Circular dependency", fn ->
        Mix.Tasks.Humo.New.Config.run([])
      end
    end)
  end

  defp write_mix(path, project, deps \\ []) do
    mkdir_write_file(
      Path.join(path, "mix.exs"),
      """
      defmodule Humo.MixProject do
        def project, do: #{inspect(project)}
        defp deps, do: #{inspect(deps)}
      end
      """
    )
  end

  defp mkdir_write_file(path, content) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
  end
end
