module Recourse
  module Helpers
    # What the page is about and what it is called: the model behind it, the record
    # on it, and the words both are read out under.
    module Resources
      # Human, plural name of the resource on the page, e.g. `Contacts`. `known_title`,
      # since a host page wearing this layout may be named after no model at all — a
      # contact's home is a `Location`, and the path is the only word for it.
      def resources_name = Recourse.known_title(controller.controller_name)

      # Singular, lowercase name of the resource, e.g. 'contact'.
      def resource_name
        Recourse.downcase resource_model.model_name.human
      end

      # Local name a row partial receives its record under, e.g. :contact.
      def resource_key
        controller.controller_name.singularize.to_sym
      end

      # The record the action built, read from the assigns rather than by ivar name.
      def resource_record
        controller_assign resource_key.to_s
      end

      # The one door to what the controller assigned. `view_assigns` is public API,
      # and every name the gem reads through it walks this method, so the untyped
      # contract with the controller's ivar names has a single seam.
      def controller_assign(name)
        controller.view_assigns[name]
      end

      # What the record on the page is called, by whatever its model labels it with —
      # and nothing where there is no record to name.
      def resource_record_label
        resource_record&.attributes&.dig resource_model.recourse_label.to_s
      end

    private

      # Resolved by the controller, where a host may have named a model the route does not.
      def resource_model
        controller_assign('recourse_model') || Recourse.model(controller.controller_name)
      end
    end
  end
end
