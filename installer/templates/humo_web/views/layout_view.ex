defmodule <%= @web_namespace %>.LayoutView do
  use <%= @web_namespace %>, :view
  import Phoenix.LiveView, only: [assign: 3]

  def root_menu(assigns) do
    ~H"""
    """
  end

  def dashboard_menu(assigns) do
    endpoint = HumoWeb.endpoint()
    routes = HumoWeb.routes()

    nav =
      Application.fetch_env!(:humo, :plugins)
      |> Enum.reject(fn {_, data} -> Map.get(data, :dashboard_links, []) == [] end)
      |> Enum.map(fn {_, data} ->
        links =
          for link <- data.dashboard_links,
              args = [endpoint, link.action | Map.get(link, :opts, [])],
              path = apply(routes, link.route, args),
              method = Map.get(link, :method, :get),
              can_path?(assigns.conn, path, method) do
            %{title: link.title, path: path, method: method}
          end

        %{title: data.title, links: links}
      end)

    assigns = assign(assigns, :nav, nav)

    ~H"""
    <div class="navbar-collapse collapse" id="navbar-menu">
      <div class="d-flex flex-column flex-md-row flex-fill align-items-stretch align-items-md-center">
        <ul class="navbar-nav">
          <%%= for plugin <- @nav do %>
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#navbar-base" data-bs-toggle="dropdown" data-bs-auto-close="false" role="button" aria-expanded="false" >
                <span class="nav-link-title">
                  <%%= plugin.title %>
                </span>
              </a>
              <div class="dropdown-menu">
                <div class="dropdown-menu-columns">
                  <div class="dropdown-menu-column">
                    <%%= for link <- plugin.links do %>
                      <%%= link link.title, to: link.path, method: link.method, class: "dropdown-item" %>
                    <%% end %>
                  </div>
                </div>
              </div>
            </li>
          <%% end %>
        </ul>
      </div>
    </div>
    """
  end

  def account_menu(assigns) do
    endpoint = HumoWeb.endpoint()
    routes = HumoWeb.routes()

    nav =
      Application.fetch_env!(:humo, :plugins)
      |> Enum.reject(fn {_, data} -> Map.get(data, :account_links, []) == [] end)
      |> Enum.flat_map(fn {_, data} ->
        for link <- data.account_links,
            args = [endpoint, link.action | Map.get(link, :opts, [])],
            path = apply(routes, link.route, args),
            method = Map.get(link, :method, :get),
            can_path?(assigns.conn, path, method) do
          %{title: link.title, path: path, method: method}
        end
      end)

    assigns = assign(assigns, :nav, nav)

    ~H"""
    <div class="navbar-nav">
      <div class="nav-item dropdown">
        <a href="#" class="nav-link d-flex lh-1 text-dark p-0" data-bs-toggle="dropdown" aria-label="Open user menu">
          <svg xmlns="http://www.w3.org/2000/svg" class="icon icon-tabler icon-tabler-user-circle" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
            <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
            <circle cx="12" cy="12" r="9"></circle>
            <circle cx="12" cy="10" r="3"></circle>
            <path d="M6.168 18.849a4 4 0 0 1 3.832 -2.849h4a4 4 0 0 1 3.834 2.855"></path>
          </svg>
          <span class="ps-2">Me</span>
        </a>
        <div class="dropdown-menu dropdown-menu-end dropdown-menu-arrow">
          <%%= for link <- @nav do %>
            <%%= link link.title, to: link.path, method: link.method, class: "dropdown-item" %>
          <%% end %>
        </div>
      </div>
    </div>
    """
  end

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
