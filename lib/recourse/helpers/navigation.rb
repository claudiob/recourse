module Recourse
  module Helpers
    # Helpers for the navbar: the trail across it, and the links and forms it draws.
    module Navigation
    private

      # Trail to the current page as [resource, title, path] triples, opening with
      # the parent a nested page sits under; a nil path is not a link.
      def resource_breadcrumbs
        crumbs = parent_breadcrumbs
        leaf = breadcrumb_leaf
        here = controller.controller_path
        return crumbs << [here, breadcrumb_name, nil] unless leaf

        crumbs << [here, breadcrumb_name, index_url] << [nil, leaf, nil]
      end

      # What the crumb naming this resource reads: its plural, or its singular where
      # the routes drew one record rather than a list. Rails routes a singular resource
      # to a plural controller, so the path says `properties` for the one property a
      # location keeps -- and the crumb over it would read `HouseCanaries` for a page
      # there is only ever one of. The same word the tab leading here took, from the
      # same place, since the two stand for one page.
      def breadcrumb_name
        return resources_name unless idless_route? controller.controller_path, 'show'

        Recourse.known_singular controller.controller_name
      end

      # Where this resource's index is, or nil where it has none: a singular resource
      # is one record reached with no id, so there is no list of it to go back to and
      # the crumb naming it is read out rather than linked.
      def index_url
        url_for action: :index if routed_action? 'index'
      end

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

      # Label for a link to a resource: the icon its model picked, then its title,
      # with the letter at `key` marked where the link answers to one.
      def resource_label(resource, title, key = nil)
        name = key ? shortcut_title(title, key) : title
        icon = Recourse.known_icon resource

        safe_join [icon && tag.i(class: "bi bi-#{icon}"), name].compact, ' '
      end

      # Only a page beneath the index names itself, and names what it is showing.
      def breadcrumb_leaf
        case controller.action_name
        when 'new', 'create' then t 'recourse.new', model: resource_name
        when 'show', 'edit', 'update' then resource_record_label
        end
      end
    end
  end
end
