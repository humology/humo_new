Code.require_file("mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Humo.NewTest do
  use ExUnit.Case, async: false
  import MixHelper
  import ExUnit.CaptureIO

  @app_name "humo_blog"

  setup do
    # The shell asks to install deps.
    # We will politely say not.
    send(self(), {:mix_shell_input, :yes?, false})
    :ok
  end

  test "returns the version" do
    Mix.Tasks.Humo.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Humo installer v" <> _]}
  end

  test "new with defaults" do
    in_tmp("new with defaults", fn ->
      Mix.Tasks.Humo.New.run([@app_name])

      assert_file("humo_blog/README.md")

      if Version.match?(System.version(), ">= 1.13.4") do
        assert_file("humo_blog/.formatter.exs", fn file ->
          assert file =~ "import_deps: [:ecto, :phoenix]"
          assert file =~ "subdirectories: [\"priv/*/migrations\"]"
          assert file =~ "plugins: [Phoenix.LiveView.HTMLFormatter]"

          assert file =~
                   "inputs: [\"*.{heex,ex,exs}\", \"{config,lib,test}/**/*.{heex,ex,exs}\", \"priv/*/seeds.exs\"]"
        end)
      else
        assert_file("humo_blog/.formatter.exs", fn file ->
          assert file =~ "import_deps: [:ecto, :phoenix]"
          assert file =~ "subdirectories: [\"priv/*/migrations\"]"

          assert file =~
                   "inputs: [\"*.{ex,exs}\", \"{config,lib,test}/**/*.{ex,exs}\", \"priv/*/seeds.exs\"]"

          refute file =~ "plugins:"
        end)
      end

      assert_file("humo_blog/mix.exs", fn file ->
        assert file =~ "app: :humo_blog"
        refute file =~ "deps_path: \"../../deps\""
        refute file =~ "lockfile: \"../../mix.lock\""
      end)

      assert_file("humo_blog/config/config.exs", fn file ->
        refute file =~ "namespace: HumoBlog"
        refute file =~ "config :humo_blog, :generators"
      end)

      assert_file("humo_blog/config/plugin.exs", fn file ->
        assert file =~ "ecto_repos: [Humo.Repo]"
      end)

      assert_file("humo_blog/config/prod.exs", fn file ->
        assert file =~ "port: 443"
      end)

      assert_file("humo_blog/config/runtime.exs", ~r/ip: {0, 0, 0, 0, 0, 0, 0, 0}/)

      assert_file("humo_blog/lib/humo_blog/application.ex", ~r/defmodule HumoBlog.Application do/)
      assert_file("humo_blog/lib/humo_blog.ex", ~r/defmodule HumoBlog do/)

      assert_file("humo_blog/mix.exs", fn file ->
        assert file =~ "mod: {HumoBlog.Application, []}"
        assert file =~ "{:jason,"
        assert file =~ "{:phoenix_live_dashboard,"
      end)

      assert_file("humo_blog/lib/humo_blog_web.ex", fn file ->
        assert file =~ "defmodule HumoBlogWeb do"
        assert file =~ "use Phoenix.View,\n        root: \"lib/humo_blog_web/templates\""
        assert file =~ "use Phoenix.HTML"
        assert file =~ "Phoenix.LiveView"
      end)

      assert_file("humo_blog/test/humo_blog_web/controllers/page_controller_test.exs")
      assert_file("humo_blog/test/humo_blog_web/views/page_view_test.exs")
      assert_file("humo_blog/test/humo_blog_web/views/error_view_test.exs")
      assert_file("humo_blog/test/humo_blog_web/views/layout_view_test.exs")
      assert_file("humo_blog/test/support/conn_case.ex")
      assert_file("humo_blog/test/test_helper.exs")

      assert_file(
        "humo_blog/lib/humo_blog_web/controllers/page_controller.ex",
        ~r/defmodule HumoBlogWeb.PageController/
      )

      assert_file(
        "humo_blog/lib/humo_blog_web/views/page_view.ex",
        ~r/defmodule HumoBlogWeb.PageView/
      )

      assert_file("humo_blog/lib/humo_blog_web/router.ex", fn file ->
        assert file =~ "defmodule HumoBlogWeb.Router"
        assert file =~ "live_dashboard"
        assert file =~ "import Phoenix.LiveDashboard.Router"
      end)

      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule HumoBlogWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        assert file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)

      assert_file("humo_blog/lib/humo_blog_web/templates/layout/root.html.heex")
      assert_file("humo_blog/lib/humo_blog_web/templates/layout/app.html.heex")
      assert_file("humo_blog/lib/humo_blog_web/templates/layout/dashboard.html.heex")
      assert_file("humo_blog/lib/humo_blog_web/templates/layout/minimal-modal.html.heex")

      # assets
      assert_file("humo_blog/.gitignore", fn file ->
        assert file =~ "/priv/static/"
        assert file =~ "humo_blog-*.tar"
        assert file =~ ~r/\n$/
      end)

      assert_file("humo_blog/config/dev.exs", fn file ->
        assert file =~ "npm: [\"run\", \"watch\"]"
        assert file =~ "mix: [\"humo.assets.watch\"]"
        assert file =~ "lib/humo_blog_web/(live|views)/.*(ex)"
        assert file =~ "lib/humo_blog_web/templates/.*(eex)"
      end)

      assert File.exists?("humo_blog/assets/vendor")

      assert File.exists?("humo_blog/assets/css/all_plugins.scss")
      assert File.exists?("humo_blog/assets/css/app.scss")
      assert File.exists?("humo_blog/assets/css/plugin.scss")
      assert File.exists?("humo_blog/assets/js/all_plugins.js")
      assert File.exists?("humo_blog/assets/js/app.js")
      assert File.exists?("humo_blog/assets/js/plugin.js")

      assert File.exists?("humo_blog/assets/build.config.mjs")
      assert File.exists?("humo_blog/assets/build.mjs")
      assert File.exists?("humo_blog/package.json")

      # Ecto
      config = ~r/config :humo, Humo.Repo,/

      assert_file("humo_blog/mix.exs", fn file ->
        assert file =~ "{:phoenix_ecto,"
        assert file =~ "aliases: aliases()"
        assert file =~ "ecto.setup"
        assert file =~ "ecto.reset"
      end)

      assert_file("humo_blog/config/dev.exs", config)
      assert_file("humo_blog/config/test.exs", config)

      assert_file("humo_blog/config/runtime.exs", fn file ->
        assert file =~ config
        assert file =~ ~S|maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []|
        assert file =~ ~S|socket_options: maybe_ipv6|

        assert file =~ """
               if System.get_env("PHX_SERVER") do
                 config :humo_blog, HumoBlogWeb.Endpoint, server: true
               end
               """

        assert file =~ ~S[host = System.get_env("PHX_HOST") || "example.com"]
        assert file =~ ~S|url: [host: host, port: 443, scheme: "https"],|
      end)

      assert_file(
        "humo_blog/config/test.exs",
        ~R/database: "humo_blog_test#\{System.get_env\("MIX_TEST_PARTITION"\)\}"/
      )

      assert_file("humo_blog/lib/humo_blog_web.ex", ~r"defmodule HumoBlogWeb")

      assert_file(
        "humo_blog/lib/humo_blog_web/endpoint.ex",
        ~r"plug Phoenix.Ecto.CheckRepoStatus, otp_app: :humo_blog"
      )

      assert_file("humo_blog/priv/repo/seeds.exs", ~r"Humo.Repo.insert!")
      assert_file("humo_blog/test/support/data_case.ex", ~r"defmodule HumoBlog.DataCase")
      assert_file("humo_blog/priv/repo/migrations/.formatter.exs", ~r"import_deps: \[:ecto_sql\]")

      # LiveView
      refute_file("humo_blog/lib/humo_blog_web/live/page_live_view.ex")

      assert File.exists?("humo_blog/assets/js/app.js")

      assert_file("humo_blog/mix.exs", fn file ->
        assert file =~ ~r":phoenix_live_view"
        assert file =~ ~r":floki"
      end)

      assert_file(
        "humo_blog/lib/humo_blog_web/router.ex",
        &assert(&1 =~ ~s[plug :fetch_live_flash])
      )

      assert_file(
        "humo_blog/lib/humo_blog_web/router.ex",
        &assert(&1 =~ ~s[plug :put_root_layout])
      )

      assert_file("humo_blog/lib/humo_blog_web/router.ex", &assert(&1 =~ ~s[PageController]))

      # Telemetry
      assert_file("humo_blog/mix.exs", fn file ->
        assert file =~ "{:telemetry_metrics,"
        assert file =~ "{:telemetry_poller,"
      end)

      assert_file("humo_blog/lib/humo_blog_web/telemetry.ex", fn file ->
        assert file =~ "defmodule HumoBlogWeb.Telemetry do"
        assert file =~ "{:telemetry_poller, measurements: periodic_measurements()"
        assert file =~ "defp periodic_measurements do"
        assert file =~ "# {HumoBlogWeb, :count_users, []}"
        assert file =~ "def metrics do"
        assert file =~ "summary(\"phoenix.endpoint.stop.duration\","
        assert file =~ "summary(\"phoenix.router_dispatch.stop.duration\","
        assert file =~ "# Database Metrics"
        assert file =~ "summary(\"humo.repo.query.total_time\","
      end)

      # Install dependencies?
      assert_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd humo_blog"
      assert msg =~ "$ mix humo.setup"

      assert_received {:mix_shell, :info, ["Then configure your database in config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Phoenix app" <> _]}

      # Gettext
      assert_file("humo_blog/lib/humo_blog_web/gettext.ex", ~r"defmodule HumoBlogWeb.Gettext")
      assert File.exists?("humo_blog/priv/gettext/errors.pot")
      assert File.exists?("humo_blog/priv/gettext/en/LC_MESSAGES/errors.po")
    end)
  end

  test "new without defaults" do
    in_tmp("new without defaults", fn ->
      Mix.Tasks.Humo.New.run([@app_name, "--no-html", "--no-gettext", "--no-dashboard"])

      # assets
      assert_file("humo_blog/.gitignore", fn file ->
        assert file =~ "/priv/static/"
      end)

      assert_file("humo_blog/config/dev.exs", fn file ->
        assert file =~ """
                 watchers: [
                   npm: ["run", "watch"],
                   mix: ["humo.assets.watch"]
                 ]
               """
      end)

      assert_file("humo_blog/assets/js/app.js")

      # Ecto
      config = ~r/config :humo, Humo.Repo,/

      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        assert file =~ "plug Phoenix.Ecto.CheckRepoStatus, otp_app: :humo_blog"
      end)

      assert_file("humo_blog/lib/humo_blog_web/telemetry.ex", fn file ->
        assert file =~ "# Database Metrics"
        assert file =~ "summary(\"humo.repo.query.total_time\","
      end)

      assert_file("humo_blog/.formatter.exs", fn file ->
        assert file =~ "import_deps: [:ecto, :phoenix]"

        assert file =~
                 "inputs: [\"*.{ex,exs}\", \"{config,lib,test}/**/*.{ex,exs}\", \"priv/*/seeds.exs\"]"

        assert file =~ "subdirectories: [\"priv/*/migrations\"]"
      end)

      assert_file("humo_blog/mix.exs", &assert(&1 =~ ~r":phoenix_ecto"))

      assert_file("humo_blog/config/plugin.exs", fn file ->
        assert file =~ "ecto_repos: [Humo.Repo]"
      end)

      assert_file("humo_blog/config/dev.exs", fn file ->
        assert file =~ config
        assert file =~ "config :phoenix, :plug_init_mode, :runtime"
      end)

      assert_file("humo_blog/config/test.exs", &assert(&1 =~ config))
      assert_file("humo_blog/config/runtime.exs", &assert(&1 =~ config))

      # No gettext
      refute_file("humo_blog/lib/humo_blog_web/gettext.ex")
      refute_file("humo_blog/priv/gettext/en/LC_MESSAGES/errors.po")
      refute_file("humo_blog/priv/gettext/errors.pot")
      assert_file("humo_blog/mix.exs", &refute(&1 =~ ~r":gettext"))
      assert_file("humo_blog/lib/humo_blog_web.ex", &refute(&1 =~ ~r"import AmsMockWeb.Gettext"))

      assert_file(
        "humo_blog/lib/humo_blog_web/views/error_helpers.ex",
        &refute(&1 =~ ~r"gettext")
      )

      assert_file("humo_blog/config/dev.exs", &refute(&1 =~ ~r"gettext"))

      # No HTML
      assert File.exists?("humo_blog/test/humo_blog_web/controllers")

      assert File.exists?("humo_blog/lib/humo_blog_web/controllers")
      assert File.exists?("humo_blog/lib/humo_blog_web/views")

      refute File.exists?("humo_blog/test/web/controllers/pager_controller_test.exs")
      refute File.exists?("humo_blog/test/views/layout_view_test.exs")
      refute File.exists?("humo_blog/test/views/page_view_test.exs")
      refute File.exists?("humo_blog/lib/humo_blog_web/controllers/page_controller.ex")
      refute File.exists?("humo_blog/lib/humo_blog_web/templates/layout/app.html.heex")
      refute File.exists?("humo_blog/lib/humo_blog_web/templates/page/index.html.heex")
      refute File.exists?("humo_blog/lib/humo_blog_web/views/layout_view.ex")
      refute File.exists?("humo_blog/lib/humo_blog_web/views/page_view.ex")

      assert_file("humo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_html"))
      assert_file("humo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_live_reload"))

      assert_file("humo_blog/lib/humo_blog_web.ex", fn file ->
        assert file =~ "defp view_helpers do"
        refute file =~ "Phoenix.HTML"
        refute file =~ "Phoenix.LiveView"
      end)

      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        refute file =~ ~r"Phoenix.LiveReloader"
        refute file =~ ~r"Phoenix.LiveReloader.Socket"
      end)

      assert_file("humo_blog/lib/humo_blog_web/views/error_view.ex", ~r".json")
      assert_file("humo_blog/lib/humo_blog_web/router.ex", &refute(&1 =~ ~r"pipeline :browser"))

      # No Dashboard
      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)

      assert_file("humo_blog/lib/humo_blog_web/router.ex", fn file ->
        refute file =~ "live_dashboard"
        refute file =~ "import Phoenix.LiveDashboard.Router"
      end)
    end)
  end

  test "new with --no-dashboard" do
    in_tmp("new with no_dashboard", fn ->
      Mix.Tasks.Humo.New.run([@app_name, "--no-dashboard"])

      assert_file("humo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_live_dashboard"))

      assert_file("humo_blog/lib/humo_blog_web/templates/layout/app.html.heex", fn file ->
        refute file =~ ~s|<%= link "LiveDashboard", to: Routes.live_dashboard_path(@conn, :home)|
      end)

      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule HumoBlogWeb.Endpoint|
        assert file =~ ~s|  socket "/live"|
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)
    end)
  end

  test "new with --no-dashboard and --no-live" do
    in_tmp("new with no_dashboard and no_live", fn ->
      Mix.Tasks.Humo.New.run([@app_name, "--no-dashboard", "--no-live"])

      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule HumoBlogWeb.Endpoint|
        assert file =~ ~s|# socket "/live"|
        refute file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)
    end)
  end

  test "new with --no-html" do
    in_tmp("new with no_html", fn ->
      Mix.Tasks.Humo.New.run([@app_name, "--no-html"])

      assert_file("humo_blog/mix.exs", fn file ->
        refute file =~ ~s|:phoenix_live_view|
        refute file =~ ~s|:phoenix_html|
        assert file =~ ~s|:phoenix_live_dashboard|
      end)

      assert_file("humo_blog/.formatter.exs", fn file ->
        assert file =~ "import_deps: [:ecto, :phoenix]"
        assert file =~ "subdirectories: [\"priv/*/migrations\"]"

        assert file =~
                 "inputs: [\"*.{ex,exs}\", \"{config,lib,test}/**/*.{ex,exs}\", \"priv/*/seeds.exs\"]"

        refute file =~ "plugins:"
      end)

      assert_file("humo_blog/lib/humo_blog_web/endpoint.ex", fn file ->
        assert file =~ ~s|defmodule HumoBlogWeb.Endpoint|
        assert file =~ ~s|socket "/live"|
        assert file =~ ~s|plug Phoenix.LiveDashboard.RequestLogger|
      end)

      assert_file("humo_blog/lib/humo_blog_web.ex", fn file ->
        refute file =~ ~s|Phoenix.HTML|
        refute file =~ ~s|Phoenix.LiveView|
      end)

      assert_file("humo_blog/lib/humo_blog_web/router.ex", fn file ->
        refute file =~ ~s|pipeline :browser|
        assert file =~ ~s|pipe_through [:fetch_session, :protect_from_forgery]|
      end)
    end)
  end

  test "new with binary_id" do
    in_tmp("new with binary_id", fn ->
      Mix.Tasks.Humo.New.run([@app_name, "--binary-id"])
      assert_file("humo_blog/config/config.exs", ~r/generators: \[binary_id: true\]/)
    end)
  end

  test "new with uppercase" do
    in_tmp("new with uppercase", fn ->
      Mix.Tasks.Humo.New.run(["humoBlog"])

      assert_file("humoBlog/README.md")

      assert_file("humoBlog/mix.exs", fn file ->
        assert file =~ "app: :humoBlog"
      end)

      assert_file("humoBlog/config/dev.exs", fn file ->
        assert file =~ ~r/config :humo, Humo.Repo,/
        assert file =~ "database: \"humoblog_dev\""
      end)
    end)
  end

  test "new with path, app and module" do
    in_tmp("new with path, app and module", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Humo.New.run([project_path, "--app", @app_name, "--module", "PhoteuxBlog"])

      assert_file("custom_path/.gitignore")
      assert_file("custom_path/.gitignore", ~r/\n$/)
      assert_file("custom_path/mix.exs", ~r/app: :humo_blog/)
      assert_file("custom_path/lib/humo_blog_web/endpoint.ex", ~r/app: :humo_blog/)
      assert_file("custom_path/config/config.exs", ~r/namespace: PhoteuxBlog/)

      assert_file(
        "custom_path/lib/humo_blog_web.ex",
        ~r/use Phoenix.Controller, namespace: PhoteuxBlogWeb/
      )
    end)
  end

  test "new with --no-install" do
    in_tmp("new with no install", fn ->
      Mix.Tasks.Humo.New.run([@app_name, "--no-install"])

      # Does not prompt to install dependencies
      refute_received {:mix_shell, :yes?, ["\nFetch and install dependencies?"]}

      # Instructions
      assert_received {:mix_shell, :info, ["\nWe are almost there" <> _ = msg]}
      assert msg =~ "$ cd humo_blog"
      assert msg =~ "$ mix humo.setup"

      assert_received {:mix_shell, :info, ["Then configure your database in config/dev.exs" <> _]}
      assert_received {:mix_shell, :info, ["Start your Phoenix app" <> _]}
    end)
  end

  test "new defaults to pg adapter" do
    in_tmp("new defaults to pg adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Humo.New.run([project_path])

      assert_file("custom_path/mix.exs", ":postgrex")

      assert_file("custom_path/config/dev.exs", [
        ~r/username: "postgres"/,
        ~r/password: "postgres"/,
        ~r/hostname: "localhost"/
      ])

      assert_file("custom_path/config/test.exs", [
        ~r/username: "postgres"/,
        ~r/password: "postgres"/,
        ~r/hostname: "localhost"/
      ])

      assert_file("custom_path/config/runtime.exs", [~r/url: database_url/])

      assert_file(
        "custom_path/config/config.exs",
        "config :humo, Humo.Repo, adapter: Ecto.Adapters.Postgres"
      )

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )
    end)
  end

  test "new with mysql adapter" do
    in_tmp("new with mysql adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Humo.New.run([project_path, "--database", "mysql"])

      assert_file("custom_path/mix.exs", ":myxql")
      assert_file("custom_path/config/dev.exs", [~r/username: "root"/, ~r/password: ""/])
      assert_file("custom_path/config/test.exs", [~r/username: "root"/, ~r/password: ""/])
      assert_file("custom_path/config/runtime.exs", [~r/url: database_url/])

      assert_file(
        "custom_path/config/config.exs",
        "config :humo, Humo.Repo, adapter: Ecto.Adapters.MyXQL"
      )

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )
    end)
  end

  test "new with sqlite3 adapter" do
    in_tmp("new with sqlite3 adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Humo.New.run([project_path, "--database", "sqlite3"])

      assert_file("custom_path/mix.exs", ":ecto_sqlite3")
      assert_file("custom_path/config/dev.exs", [~r/database: .*_dev.db/])
      assert_file("custom_path/config/test.exs", [~r/database: .*_test.db/])
      assert_file("custom_path/config/runtime.exs", [~r/database: database_path/])

      assert_file(
        "custom_path/config/config.exs",
        "config :humo, Humo.Repo, adapter: Ecto.Adapters.SQLite3"
      )

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )

      assert_file("custom_path/.gitignore", "*.db")
      assert_file("custom_path/.gitignore", "*.db-*")
    end)
  end

  test "new with mssql adapter" do
    in_tmp("new with mssql adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")
      Mix.Tasks.Humo.New.run([project_path, "--database", "mssql"])

      assert_file("custom_path/mix.exs", ":tds")

      assert_file("custom_path/config/dev.exs", [
        ~r/username: "sa"/,
        ~r/password: "some!Password"/
      ])

      assert_file("custom_path/config/test.exs", [
        ~r/username: "sa"/,
        ~r/password: "some!Password"/
      ])

      assert_file("custom_path/config/runtime.exs", [~r/url: database_url/])

      assert_file(
        "custom_path/config/config.exs",
        "config :humo, Humo.Repo, adapter: Ecto.Adapters.Tds"
      )

      assert_file("custom_path/test/support/conn_case.ex", "DataCase.setup_sandbox(tags)")

      assert_file(
        "custom_path/test/support/data_case.ex",
        "Ecto.Adapters.SQL.Sandbox.start_owner"
      )
    end)
  end

  test "new with invalid database adapter" do
    in_tmp("new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!(), "custom_path")

      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Humo.New.run([project_path, "--database", "invalid"])
      end
    end)
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Humo.New.run(["007invalid"])
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Humo.New.run(["valid", "--app", "007invalid"])
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Humo.New.run(["valid", "--module", "not.valid"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Humo.New.run(["string"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Humo.New.run(["valid", "--app", "mix"])
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Humo.New.run(["valid", "--module", "String"])
    end
  end

  test "invalid options" do
    assert_raise Mix.Error, ~r/Invalid option: -d/, fn ->
      Mix.Tasks.Humo.New.run(["valid", "-database", "mysql"])
    end
  end

  test "new without args" do
    in_tmp("new without args", fn ->
      assert capture_io(fn -> Mix.Tasks.Humo.New.run([]) end) =~
               "Creates a new Phoenix project."
    end)
  end
end
