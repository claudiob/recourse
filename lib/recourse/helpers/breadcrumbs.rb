module Recourse
  module Helpers
    # The trail across the navbar: what each crumb reads, and which of them lead
    # anywhere.
    module Breadcrumbs
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

      # A crumb's words, which a phone drops where the icon stands for them: the row at
      # the top has a search box and a button to fit beside the trail.
      def crumb_label(resource, title)
        icon = Recourse.known_icon resource
        return title unless icon

        word = tag.span title, class: 'recourse-crumb-word'

        safe_join [tag.i(class: "bi bi-#{icon}"), word], ' '
      end

      # What the tab calls this page: what the trail ends with, the resource it is of
      # where the record names nothing, and the app's own name where neither answers.
      def page_title
        breadcrumb_leaf.presence || breadcrumb_name.presence || app_name
      end

      def app_name = Rails.application.class.module_parent_name

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
