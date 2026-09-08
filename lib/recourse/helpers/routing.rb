module Recourse
  module Helpers
    # What the router will answer, which is what decides whether a link is drawn.
    module Routing
    private

      # True where this controller both implements an action and has a route drawn to
      # it. Either alone is a link that 404s or raises. The path is the one being
      # served unless a caller names another: a nested page asks about the resource's
      # own routes, which is where the member actions a nesting leaves out are drawn.
      def routed_action?(action, path = controller.controller_path)
        return false unless controller.class.action_methods.include? action

        routed? path, action
      end

      def routed?(controller_path, action)
        # The route set as one set of "controller#action" words, built once per
        # render: the table asks four times per row, and routes never change mid-page.
        @recourse_routed ||= Rails.application.routes.routes.to_set do |route|
          "#{route.defaults[:controller]}##{route.defaults[:action]}"
        end

        @recourse_routed.include? "#{controller_path}##{action}"
      end
    end
  end
end
