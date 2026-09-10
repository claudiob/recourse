module Recourse
  module Helpers
    # What a page knows about the records either side of it: the one a nested route
    # names above it, and the ones a count or a tab reaches below.
    module Parents
    private

      # The record a nested route names above this page, or nil at the top level.
      def resource_parent
        controller_assign 'recourse_parent'
      end

      # The belongs_to that record is reached through, which names the foreign key
      # every row on the page shares.
      def resource_parent_association
        controller_assign 'recourse_parent_association'
      end

      # The page a nested resource keeps under one record: the index of its children at
      # `/counties/1/zips`, or -- where the routes drew a singular resource -- the one
      # record itself at `/places/5/zip`, reached with no id of its own. The key is
      # named after the path the children are nested under rather than after the page
      # being served, since a page nested one level up is served by another controller
      # entirely.
      def nested_url(record, path, nested)
        url_for controller: "/#{nested}", action: :index,
                "#{path.split('/').last.singularize}_id": record.id
      end

      # The crumbs a nested page sits under: the parent's own index, then the record
      # the path names — `Counties`, then `Alameda County`, before `ZIPs`. The
      # record's crumb links to its show page, where one is routed to link to.
      def parent_breadcrumbs
        parent = resource_parent
        return [] unless parent

        path = Recourse.parent_of controller.controller_path
        [
          [path, Recourse.title(path), parent_url(path, :index)],
          [nil, parent_title(parent), parent_url(path, :show, id: parent)],
        ]
      end

      # Where this resource's own routes are drawn. A nested route answers the
      # collection actions and no more, so a member page — and a count reaching one
      # of the resource's own nested indexes — is looked up above the nesting: this
      # resource's name, drawn where its parent was drawn, so `admin/counties/zips`
      # leaves `admin/zips` however many segments the nesting took. Unless the nesting
      # drew a member page of its own: a county a provider serves is read under that
      # provider and nowhere else, and its pages are where the host put them.
      def resource_controller_path
        path = controller.controller_path
        return path if !resource_parent || routed?(path, 'show') || routed?(path, 'edit')

        module_of = Recourse.parent_of(path).rpartition('/').first

        [module_of.presence, path.split('/').last].compact.join '/'
      end

      def parent_title(parent)
        # Forty characters of the title, no more: a record named by an address or a
        # sentence would otherwise walk the crumb into the navbar's search form.
        truncate Recourse.record_title(parent), length: 40
      end

      # One of the parent's own pages, or nil where the host drew no route to it —
      # a crumb without a path is read out rather than linked. Both crumbs ask,
      # since a parent reached through a nesting need not be listed or shown at all.
      def parent_url(path, action, **)
        return unless routed? path, action

        url_for controller: "/#{path}", action:, **
      end
    end
  end
end
