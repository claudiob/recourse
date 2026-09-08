module Recourse
  module Helpers
    # Helpers for the cells of a table and the fields of a form.
    module Cells
      # One cell: a heading in the header row, the block's output in every other.
      # Public because a row partial of a host's own is written out of these, and
      # is rendered once for the header row and once for each row after it.
      def column(header:, **, &)
        return tag.th(header, scope: :col, **) if @recourse_headers

        tag.td(capture(&), 'data-cell': header, **)
      end

    private

      # Columns the table shows: every attribute that is not encrypted and not
      # read-only, less the primary key — an id is how a row is addressed, not
      # something to read about it — in the order `Recourse.ordered` reads a row,
      # which is what leaves the counts last of all, past even the timestamps.
      def resource_columns
        Recourse.ordered resource_model, resource_model.column_names - hidden_columns
      end

      # What no table shows, less whatever the model asked to draw anyway. Each of
      # the four below is a default the gem picks, and a host is what answers for
      # its own screens — so naming one overrules it.
      def hidden_columns
        columns_hidden_by_default - Array(resource_model.recourse_displayed).map(&:to_s)
      end

      # Ciphertext, the id that addresses the row, the parent a nested route already
      # names, the column an arranged table is ordered by, the timestamps and every JSON
      # payload — what a machine keeps rather than what a row is about — and whatever the
      # model asked to hide, the one of these a host decides without the override above.
      def columns_hidden_by_default
        [
          resource_model.recourse_encrypted_names, resource_model.primary_key, TIMESTAMPS,
          resource_parent_association&.foreign_key, arranged_columns, json_columns,
          Recourse.hidden_columns(resource_model),
        ].flatten.compact
      end

      # A place in an order somebody set is what the order of the rows already says, so
      # no table draws one. Read at a level it is not counted at it says even less: the
      # same figure down a column, once per parent. Both are dropped — the model's own,
      # and the one this listing is arranged by, which is not always the same column.
      def arranged_columns
        [Recourse.position_columns(resource_model), controller_assign('recourse_position')]
      end

      # Columns a form offers — less the parent a nested route has already
      # answered: a comment under `/posts/2` is for post 2, not for one picked
      # from a menu, so no field asks.
      def editable_columns
        Recourse.editable_columns(resource_model) - Array(resource_parent_association&.foreign_key)
      end

      # Columns the show page reads out: what the form offers, what the model draws
      # anyway, and the timestamps last — a computed column is read where it is not typed.
      def shown_columns
        drawn = Array(resource_model.recourse_displayed).map(&:to_s) - TIMESTAMPS
        (editable_columns + drawn).uniq + (TIMESTAMPS & resource_model.column_names)
      end

      # Heading for a column, which a host app can translate like any attribute. A
      # counter is headed with what it counts — `ZIPs`, not `ZIPs count` — since the
      # column holds a number and the heading says what the number is of.
      def resource_column_title(column)
        counted = resource_model.recourse_counters[column]
        return resource_model.human_attribute_name column unless counted

        Recourse.model_title counted.klass
      end

      # Value for one cell, formatted according to what the column holds.
      def resource_cell(resource, column)
        association = key_association column
        return search_highlight named_cell(resource, association), column if association

        value = resource.attributes[column]
        counted = resource_model.recourse_counters[column]

        # A count is the bare number — the icon in the heading already says what it
        # counts — linking to the counted rows where a block nested their index here.
        return counter_cell resource, value, counted if counted

        # A list is counted rather than drawn: the values are the record's own page to
        # read out, and a column of them inside a column of them is not a table.
        return listed_count value if attribute_kind(column) == :list

        # The same ladder the show page comes down, with the search's own marking
        # handed in: a table is the only page a search ever reached.
        formatted_attribute(column, value) { |text| search_highlight text, column }
      end
    end
  end
end
