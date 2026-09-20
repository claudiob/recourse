module Recourse
  module Helpers
    # The action columns a row opens with: a look at a record, a change to it, and —
    # where the routes drew nowhere else to put it — the end of it.
    module Actions
      # The pages a record has and the one thing done to it without a page, named as
      # the concepts an icon set knows rather than as one set's own word for them, so
      # what draws them is Unicon's business here as everywhere else. A row's links and
      # a card's tabs read the same map, so the two cannot drift apart — and its order
      # is the order a row opens with.
      ICONS = { show: :view, edit: :edit, destroy: :delete }.freeze

    private

      # Which of those this table draws a column for. Read into a local by the
      # table, so the routes are asked once per render rather than twice for the
      # heading and twice more for every row.
      def resource_actions
        ICONS.keys.select { |action| resource_action? action }
      end

      # An action column's heading: the icon on the header row — the column is as
      # narrow as the icon in it, with no room for a word — and the action's own
      # word in every other, which is what each `data-cell` labels itself with.
      def action_header(action)
        label = t "recourse.#{action}"
        return label unless @recourse_headers

        icon_heading ICONS[action], label
      end

      # Whether a record's own page is there to be linked to, wherever its routes
      # were drawn: a nested table's rows lead to the resource's own pages, the ones
      # a nested route leaves to it, so the columns are the same either way. A delete
      # is the exception, standing on the table only where no page would carry it.
      def resource_action?(action)
        return destroy_action_path.present? if action == :destroy

        routed_action? action.to_s, resource_controller_path
      end

      # Where a row is deleted from, or nil. The Delete button stands on the edit page
      # where the routes drew one; a resource routed `destroy` and no `edit` — a file
      # attached to a record, a row joining two — has no page of its own to carry it,
      # so the table does, at whichever of the two paths drew the route: the nesting's
      # own, or the resource's. Remembered per render, since the table asks per row.
      def destroy_action_path
        return @recourse_destroy_path if defined? @recourse_destroy_path

        paths = [controller.controller_path, resource_controller_path].uniq
        @recourse_destroy_path = if paths.none? { |path| routed_action? 'edit', path }
                                   paths.find { |path| routed_action? 'destroy', path }
                                 end
      end

      # The icon linking to one of those pages, or the button that deletes the row, or
      # nothing where the page is not routed.
      def resource_action_link(action, record)
        return destroy_button record if action == :destroy

        path = resource_action_path action, record
        return unless path

        turbo_link_to icon_tag(ICONS[action]), path, aria: { label: t("recourse.#{action}") }
      end

      # Named by controller rather than by action alone: on a nested page the two
      # differ, and a bare `action:` would look for the member route the nesting
      # does not draw.
      def resource_action_path(action, record)
        return unless resource_action? action

        url_for controller: "/#{resource_controller_path}", action: action, id: record
      end

      # The icon alone, red for what it does, and the same warning the edit page's button
      # carries in front of it, which the bundle draws as its dialog. Out of the frame
      # the table is drawn in, like every other action in the row: what a delete lands on
      # is a whole page with a message over it, and answering inside the frame would keep
      # the table and throw the message away.
      def destroy_button(record)
        path = url_for controller: "/#{destroy_action_path}", action: :destroy, id: record

        confirm_button_to icon_tag(ICONS[:destroy], class: 'fg-danger'), path,
                          confirm: destroy_warning(record), method: :delete,
                          class: 'btn btn-sm btn-link btn-icon p-0',
                          aria: { label: t('recourse.delete', model: resource_name) },
                          form: { data: { turbo_frame: '_top' } }
      end
    end
  end
end
