module Recourse
  module Helpers
    # The links in a table's headings, and the caret naming the order in force.
    module Sorts
      # Caret for the direction a column is sorted by. A column nobody sorted by
      # gets none: an arrow on every heading says nothing about the order in force.
      SORT_CARETS = { 'asc' => 'caret-up-fill', 'desc' => 'caret-down-fill' }.freeze

      # A heading for a column: a link that sorts the table by it where the model
      # allows that, and the plain title everywhere else. Only the header row draws
      # the link, so the `data-cell` on every other row stays readable text.
      #
      # Named apart from Ransack's `sort_link`, which it calls: sharing the name
      # would take that helper away from every view this gem's controllers render.
      def sort_header(column, title = nil)
        title ||= sort_title column
        return title unless @recourse_headers && sortable_column?(column)

        sort_link resource_search, column.to_sym, hide_indicator: true, page: nil do
          safe_join [title, sort_caret(column)].compact, ' '
        end
      end

    private

      # What the column is called — except a counter's header row, which shows the
      # counted model's icon: the cells under it are bare figures, and the icon is what
      # says what they count.
      #
      # The column's own name even where a foreign key is typed rather than picked. A
      # form names the attribute it wants typed, `ZIP code` rather than `ZIP`, because
      # a box has to say what goes in it; a heading stands over what a record is called
      # and nobody types anything under it — and `Location address line 1` over a column
      # of addresses reads as a form's question asked where there is no form.
      def sort_title(column)
        counted = resource_model.recourse_counters[column.to_s]
        return counter_title counted if counted && @recourse_headers

        resource_column_title column.to_s
      end

      # An arranged table offers no heading a reader can sort by: the order is one
      # somebody set, and a second way to read the same rows would contradict it.
      # Asked here rather than in `_table`, so a row partial of a host's own — which
      # draws its headings through `sort_header` like every other — needs no edit the
      # day its model becomes arranged.
      def sortable_column?(column)
        return false if arranged?

        resource_model.ransortable_attributes.include? column.to_s
      end

      def sort_caret(column)
        sort = resource_search.sorts.find { |one| one.name == column.to_s }
        icon = SORT_CARETS[sort&.dir]
        return unless icon

        tag.i class: "bi bi-#{icon}"
      end

      # Carried through the form as a hidden field, so searching keeps the order a
      # heading asked for. Ransack's own links write one sort, and write it as a
      # string; an array from anywhere else is left behind rather than mangled.
      def sort_param
        sort = query_params[:s]
        sort if sort.is_a? String
      end
    end
  end
end
