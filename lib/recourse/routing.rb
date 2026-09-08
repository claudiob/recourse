# Reopened for the one question a controller and a view both ask of the router.
module Recourse
  # What the router will answer. A view asks it through `Helpers::Routing`, which keeps
  # a set of its own for the table that asks four times a row; a controller asks here,
  # at most once a request, so this scans rather than remembering — a set kept between
  # requests would outlive the routes file it was built from.
  module Routing
    # True where a route is drawn to this controller and action.
    def routed?(controller_path, action)
      Rails.application.routes.routes.any? do |route|
        route.defaults[:controller] == controller_path && route.defaults[:action] == action.to_s
      end
    end
  end

  extend Routing
end
