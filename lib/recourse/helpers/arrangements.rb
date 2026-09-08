module Recourse
  module Helpers
    # What a table somebody arranged by hand draws, and what it stops drawing.
    module Arrangements
      # The concept the grip beside each row is drawn as, named for an icon set to
      # answer for rather than spelled as one set's own class: Bootstrap draws it
      # `grip-vertical`, iOS as the three bars it has used for a reorder grabber
      # since the first table view, and Material as `drag_indicator`.
      HANDLE = :drag

    private

      # Whether these rows are ones a reader arranges, which the controller settled
      # before the page began: a listing may be arranged by a column the model never
      # nominated, and only the controller knows which.
      def arranged? = controller_assign('recourse_position').present?

      # The grip's heading: the icon on the header row, since the column is as narrow
      # as what sits in it, and the word in every other for the `data-cell` a stacked
      # table labels itself with.
      def arrangement_header
        label = t 'recourse.arrange'
        return label unless @recourse_headers

        icon_heading HANDLE, label
      end

      # The grip itself. A method rather than the constant, so a template reaches for
      # nothing a view context cannot resolve.
      def arrangement_handle
        icon_tag HANDLE
      end

      # What the body carries so a drop knows what it is counting from: the rows are a
      # page rather than the table, so the index a drag reports is short by whatever
      # the pages before it hold.
      def arrangement_data(pagy)
        {
          controller: 'sortable', sortable_offset_value: pagy&.offset.to_i,
          sortable_message_value: t('recourse.position_updated'),
        }
      end

      # And what each row carries: where to write the place it ends up. One URL per
      # row rather than one template on the body, so a host's own row partial and a
      # nested table alike are addressed by the routes rather than by string-building.
      def arrangement_url(record)
        url_for controller: "/#{controller.controller_path}/positions", action: :update,
                "#{resource_key}_id": record
      end
    end
  end
end
