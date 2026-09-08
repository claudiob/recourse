module Recourse
  module Helpers
    # The action columns a row opens with: a look at a record, then a change to it.
    module Actions
      # The two pages a record has, named as the concepts an icon set knows rather
      # than as one set's own word for them, so what draws them is Unicon's business
      # here as everywhere else. A row's links and a card's tabs read the same map,
      # so the two cannot drift apart — and its order is the order a row opens with.
      ICONS = { show: :view, edit: :edit }.freeze

    private

      # Which of those two this table draws a column for. Read into a local by the
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
      # a nested route leaves to it, so the columns are the same either way.
      def resource_action?(action)
        routed_action? action.to_s, resource_controller_path
      end

      # The icon linking to one of those pages, or nothing where the page is not
      # routed. Which of the two it is, is the whole difference between them.
      def resource_action_link(action, record)
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
    end
  end
end
