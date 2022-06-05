defmodule HumoNew.Single do
  @moduledoc false
  use HumoNew.Generator
  alias HumoNew.Project

  template :new, [
    {:eex,  "humo_single/config/config.exs",             :project, "config/config.exs"},
    {:eex,  "humo_single/config/dev.exs",                :project, "config/dev.exs"},
    {:eex,  "humo_single/config/prod.exs",               :project, "config/prod.exs"},
    {:eex,  "humo_single/config/runtime.exs",            :project, "config/runtime.exs"},
    {:eex,  "humo_single/config/test.exs",               :project, "config/test.exs"},
    {:eex,  "humo_single/config/plugin.exs",             :project, "config/plugin.exs"},
    {:eex,  "humo_single/lib/app_name/application.ex",   :project, "lib/:app/application.ex"},
    {:eex,  "humo_single/lib/app_name.ex",               :project, "lib/:app.ex"},
    {:keep, "humo_web/controllers",                      :project, "lib/:lib_web_name/controllers"},
    {:eex,  "humo_web/views/error_helpers.ex",           :project, "lib/:lib_web_name/views/error_helpers.ex"},
    {:eex,  "humo_web/views/error_view.ex",              :project, "lib/:lib_web_name/views/error_view.ex"},
    {:eex,  "humo_web/endpoint.ex",                      :project, "lib/:lib_web_name/endpoint.ex"},
    {:eex,  "humo_web/router.ex",                        :project, "lib/:lib_web_name/router.ex"},
    {:eex,  "humo_web/plugin_router.ex",                 :project, "lib/:lib_web_name/plugin_router.ex"},
    {:eex,  "humo_web/telemetry.ex",                     :project, "lib/:lib_web_name/telemetry.ex"},
    {:eex,  "humo_single/lib/app_name_web.ex",           :project, "lib/:lib_web_name.ex"},
    {:eex,  "humo_single/mix.exs",                       :project, "mix.exs"},
    {:eex,  "humo_single/README.md",                     :project, "README.md"},
    {:eex,  "humo_single/formatter.exs",                 :project, ".formatter.exs"},
    {:eex,  "humo_single/gitignore",                     :project, ".gitignore"},
    {:eex,  "humo_test/support/conn_case.ex",            :project, "test/support/conn_case.ex"},
    {:eex,  "humo_single/test/test_helper.exs",          :project, "test/test_helper.exs"},
    {:keep, "humo_test/controllers",                     :project, "test/:lib_web_name/controllers"},
    {:eex,  "humo_test/views/error_view_test.exs",       :project, "test/:lib_web_name/views/error_view_test.exs"},
  ]

  template :gettext, [
    {:eex,  "humo_gettext/gettext.ex",               :project, "lib/:lib_web_name/gettext.ex"},
    {:eex,  "humo_gettext/en/LC_MESSAGES/errors.po", :project, "priv/gettext/en/LC_MESSAGES/errors.po"},
    {:eex,  "humo_gettext/errors.pot",               :project, "priv/gettext/errors.pot"}
  ]

  template :html, [
    {:eex, "humo_web/controllers/page_controller.ex",         :project, "lib/:lib_web_name/controllers/page_controller.ex"},
    {:eex, "humo_web/views/page_view.ex",                     :project, "lib/:lib_web_name/views/page_view.ex"},
    {:eex, "humo_test/controllers/page_controller_test.exs",  :project, "test/:lib_web_name/controllers/page_controller_test.exs"},
    {:eex, "humo_test/views/page_view_test.exs",              :project, "test/:lib_web_name/views/page_view_test.exs"},
    {:eex, "humo_web/templates/layout/root.html.heex",        :project, "lib/:lib_web_name/templates/layout/root.html.heex"},
    {:eex, "humo_web/templates/layout/app.html.heex",         :project, "lib/:lib_web_name/templates/layout/app.html.heex"},
    {:eex, "humo_web/templates/layout/live.html.heex",        :project, "lib/:lib_web_name/templates/layout/live.html.heex"},
    {:eex, "humo_web/views/layout_view.ex",                   :project, "lib/:lib_web_name/views/layout_view.ex"},
    {:eex, "humo_web/templates/page/index.html.heex",         :project, "lib/:lib_web_name/templates/page/index.html.heex"},
    {:eex, "humo_test/views/layout_view_test.exs",            :project, "test/:lib_web_name/views/layout_view_test.exs"},
  ]

  template :ecto, [
    {:keep, "humo_ecto/priv/repo/migrations", :app, "priv/repo/migrations"},
    {:eex,  "humo_ecto/formatter.exs",        :app, "priv/repo/migrations/.formatter.exs"},
    {:eex,  "humo_ecto/seeds.exs",            :app, "priv/repo/seeds.exs"},
    {:eex,  "humo_ecto/data_case.ex",         :app, "test/support/data_case.ex"},
  ]

  template :assets, [
    {:eex,  "humo_assets/app.js",       :web, "assets/js/app.js"},
    {:eex,  "humo_assets/plugin.js",    :web, "assets/js/plugin.js"},
    {:eex,  "humo_assets/package.json", :web, "package.json"},
    {:keep, "humo_assets/vendor",       :web, "assets/vendor"},
    {:keep, "humo_assets/css",          :web, "assets/css"},
    {:keep, "humo_assets/static",       :web, "assets/static"}
  ]

  template :static, [
  ]

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    %Project{project | project_path: project.base_path}
    |> put_app()
    |> put_root_app()
    |> put_web_app()
  end

  defp put_app(%Project{base_path: base_path} = project) do
    %Project{project | app_path: base_path}
  end

  defp put_root_app(%Project{app: app, opts: opts} = project) do
    %Project{project |
             root_app: app,
             root_mod: Module.concat([opts[:module] || Macro.camelize(app)])}
  end

  defp put_web_app(%Project{app: app} = project) do
    %Project{project |
             web_app: app,
             lib_web_name: "#{app}_web",
             web_namespace: Module.concat(["#{project.root_mod}Web"]),
             web_path: project.project_path}
  end

  def generate(%Project{} = project) do
    copy_from project, __MODULE__, :new

    gen_ecto(project)
    if Project.html?(project), do: gen_html(project)
    if Project.gettext?(project), do: gen_gettext(project)

    gen_assets(project)
    project
  end

  def gen_html(project) do
    copy_from project, __MODULE__, :html
  end

  def gen_gettext(project) do
    copy_from project, __MODULE__, :gettext
  end

  def gen_ecto(project) do
    copy_from project, __MODULE__, :ecto
    gen_ecto_config(project)
  end

  def gen_assets(%Project{} = project) do
    copy_from project, __MODULE__, :assets
    copy_from project, __MODULE__, :static
  end
end
