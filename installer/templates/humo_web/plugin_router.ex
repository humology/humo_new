defmodule <%= @web_namespace %>.PluginRouter do
  @moduledoc false

  use HumoWeb.PluginRouterBehaviour

  # def root() do
  #   quote location: :keep do
  #     resources "/pages", <%= @web_namespace %>.PageController
  #   end
  # end

  # def dashboard() do
  #   quote location: :keep do
  #     resources "/pages", <%= @web_namespace %>.Dashboard.PageController
  #   end
  # end
end
