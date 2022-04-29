defmodule HumoNew.Mailer do
  @moduledoc false
  use HumoNew.Generator
  alias HumoNew.Project

  template :new, [
    {:eex,  "humo_mailer/lib/app_name/mailer.ex", :app, "lib/:app/mailer.ex"}
  ]

  def prepare_project(%Project{} = project) do
    app_path = Path.expand(project.base_path)
    project_path = Path.dirname(Path.dirname(app_path))

    %Project{project |
             in_umbrella?: true,
             app_path: app_path,
             project_path: project_path}
  end

  def generate(%Project{} = project) do
    inject_umbrella_config_defaults(project)
    copy_from project, __MODULE__, :new
    project
  end
end
