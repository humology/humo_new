# This file is responsible for configuring your plugin application
#
# This configuration can be partially overriden by plugin that has
# this application as dependency

# General application configuration
import Config

config :<%= @app_name %>,
  ecto_repos: [Humo.Repo]

# Warehouse manages resources, which are used by authorization system.
# Each plugin has it's own resources.
# Example of Warehouse configuration:
#
# config :humo, Humo.Warehouse,
#   <%= @app_name %>: [<%= @app_module %>.PagesService.Page]

# Configures plugin router.
# Each plugin can have it's routes
# Routes can be added to root path /
# Also can be added to dashboard path /humo/
#
# config :humo, HumoWeb.PluginsRouter,
#   <%= @app_name %>: <%= @web_namespace %>.PluginRouter

# Add browser plugs
#
# config :humo, HumoWeb.BrowserPlugs,
#   <%= @app_name %>: [{<%= @web_namespace %>.AssignUserPlug, true}]

# Example of dashboard menu plugin links:
#
# config :humo, :plugins,
#   <%= @app_name %>: %{
#     title: "Accounts",
#     dashboard_links: [
#       %{title: "Users", route: :dashboard_<%= @app_name %>_user_path, action: :index}
#     ],
#     account_links: [
#       %{title: "Login", route: :<%= @app_name %>_session_path, action: :new},
#       %{title: "Profile", route: :<%= @app_name %>_profile_user_path, action: :show},
#       %{title: "Logout", route: :<%= @app_name %>_session_path, action: :delete, method: :delete}
#     ]
#   }
