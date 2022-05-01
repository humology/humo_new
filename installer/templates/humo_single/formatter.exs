[
  import_deps: [:ecto, :phoenix],
  subdirectories: ["priv/*/migrations"],<%= if @html and Version.match?(System.version(), ">= 1.13.4") do %>
  plugins: [Phoenix.LiveView.HTMLFormatter],<% end %>
  inputs: [<%= if @html and Version.match?(System.version(), ">= 1.13.4") do %>"*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"<% else %>"*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"<% end %>, "priv/*/seeds.exs"]
]
