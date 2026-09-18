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

    # True where that route needs no id of its own — a collection action, or a singular
    # resource's, which is what tells `recourse :memo` from `recourses :memos`: Rails
    # routes both to the same plural controller, and only the route says which it is.
    # Nil where no such route is drawn at all, which is a third answer and reads as one.
    def idless_route?(controller_path, action)
      route = Rails.application.routes.routes.find do |one|
        one.defaults[:controller] == controller_path && one.defaults[:action] == action.to_s
      end

      route&.required_parts&.exclude? :id
    end
  end

  extend Routing
end
