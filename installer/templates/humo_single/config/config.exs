# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if Path.expand("humo_#{config_env()}.exs", __DIR__) |> File.exists?(),
  do: import_config("humo_#{config_env()}.exs")<%= if @namespaced? || @generators do %>

config :<%= @app_name %><%= if @namespaced? do %>,
  namespace: <%= @app_module %><% end %><%= if @generators do %>,
  generators: <%= inspect @generators %><% end %><% end %>

# Configures Humo.Repo adapter
config :humo, Humo.Repo, adapter: <%= inspect @adapter_module %>

# Configures the endpoint
config :<%= @app_name %>, <%= @endpoint_module %>,
  url: [host: "localhost"],
  render_errors: [view: <%= @web_namespace %>.ErrorView, accepts: ~w(<%= if @html do %>html <% end %>json), layout: false],
  pubsub_server: <%= @app_module %>.PubSub,
  live_view: [signing_salt: "<%= @lv_signing_salt %>"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
