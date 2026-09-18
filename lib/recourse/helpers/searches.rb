module Recourse
  module Helpers
    # The form above a table: the box, its filters, and the marks a match earns.
    module Searches
      # A value with the searched text marked, so a row says why it is in the table.
      # Only what the search looked through is marked: a word marked in a column
      # nobody searched would claim a match that never happened. Public because a
      # row partial of a host's own draws its cells itself and marks them the same.
      def search_highlight(value, column)
        term = query_params[resource_search_field]
        return value if term.blank? || !searched_column?(column)

        highlight value.to_s, term
      end

    private

      # The form above the table, or nothing at all where the model offers neither
      # of the two things it holds: a box to type in, and menus to narrow by. Either
      # earns it — a table with nothing worth searching may still be worth filtering,
      # and a model whose only columns are an enum and a foreign key is the case.
      def search_form
        # Nor on a table somebody arranges, for the reason a heading stands down: a
        # search or a filter shortens the page, and a drop on a shortened one reports
        # a place among the rows that are left rather than a position in the table.
        return if arranged?

        field = resource_search_field
        filters = resource_filter_fields
        return if field.blank? && filters.empty?

        render 'recourses/search', query: resource_search, url: search_url,
                                   field: field, prompt: resource_search_prompt,
                                   filters: filters, sort: sort_param
      end

      # Where the form submits: this page's own shape, so a filter picked on the map or
      # on the calendar answers with the map or the calendar. Only a shape's format goes
      # into the address — the table is the page at its own, with no extension at all.
      def search_url
        format = request.format.symbol

        url_for action: :index, format: (format if Recourse::SHAPES.include? format)
      end

      # The model's search field, less the reach-through a nested route already
      # answered: a page pinned to one provider offers no box to search them all.
      def resource_search_field
        resource_model.search_field except: resource_parent_association
      end

      def resource_search_prompt
        resource_model.search_prompt except: resource_parent_association
      end

      # A foreign key's cell shows a label from the other table, so what decides is
      # whether the search reaches through that association rather than reads a column.
      # And a row drawn out of the record a key points at marks that record's label with
      # the same helper — `name` on a page of sectors is the provider's — so a column this
      # model has none of is looked for among the labels the search reached through.
      def searched_column?(column)
        association = belongs_to_association(column.to_s) || labelled_association(column.to_s)
        return resource_model.recourse_searchable_associations.include? association if association

        resource_model.recourse_searchable_columns.include? column.to_s
      end

      def labelled_association(column)
        return if resource_model.column_names.include? column

        resource_model.recourse_searchable_associations.find do |one|
          one.klass.recourse_label.to_s == column
        end
      end

      # The search the action built, under Ransack's own name for one.
      def resource_search
        controller_assign 'q'
      end
    end
  end
end
