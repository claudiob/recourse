module Recourse
  module Helpers
    # The links and forms the navbar draws, and where each of them goes.
    module Navigation
    private

      # A link out of a table. Every cell is inside the results frame, and the page a
      # cell links to has no frame of that name, so Turbo would replace the table with
      # `Content missing` rather than leaving the page. `_top` is what leaves it.
      # Takes everything `link_to` takes, and a `data:` of its own still wins.
      def turbo_link_to(name, path, **options)
        data = { turbo_frame: '_top' }.merge options.fetch(:data, {})

        link_to name, path, **options, data: data
      end

      # Where a form submits: the action that saves it, in the namespace the resource
      # was drawn in. `form_with model:` would ask polymorphic routing instead, which
      # knows the model and not the namespace, and names a route that does not exist.
      def resource_form_url(record)
        return url_for action: :create if record.new_record?

        url_for action: :update, id: record
      end

      # Path to this resource's new page, or nil when there is not one to link to.
      def new_resource_path
        return unless routed_action? 'new'

        url_for action: :new
      end

      # True where `create` is routed with no `new` to draw a form: the navbar then
      # offers a Create button in the Add link's place. Routing it that way is the
      # host saying a bare record can stand — the routes are the whole check.
      def bare_create?
        new_resource_path.nil? && routed_action?('create')
      end

      # Label for a sidebar link: the icon its model picked, then its title, with the
      # letter at `key` marked where the link answers to one. The words are wrapped where
      # an icon stands beside them, so a phone can keep the icon and drop them.
      def resource_label(resource, title, key = nil)
        name = key ? shortcut_title(title, key) : title
        icon = Recourse.known_icon resource
        return name unless icon

        safe_join [tag.i(class: "bi bi-#{icon}"), tag.span(name, class: 'recourse-nav-word')], ' '
      end
    end
  end
end
