module Recourse
  module Helpers
    # The menus beside a search box: one per foreign key a table can be narrowed by,
    # and one per column whose values are a known few.
    module Filters
    private

      # The filters this page draws, as the markup each one is. A declared filter
      # that draws nothing falls out here — a foreign key whose label is typed
      # rather than picked — so what is left is what a form would hold, which is
      # what decides whether there is a form at all.
      def resource_filter_fields
        resource_filters.filter_map { |predicate, options| filter_field predicate, **options }
      end

      # The model's filters, less the one a nested route already answered:
      # /markets/1/sectors is filtered by market_id in the URL itself, and a menu
      # for it would only offer to re-ask — or to contradict — the address.
      def resource_filters
        parent = resource_parent_association
        filters = resource_model.filter_fields
        return filters unless parent

        filters.except "#{parent.foreign_key}_in"
      end

      # One filter: the values a column of its own admits, or a menu of the records a
      # foreign key points at, holding whichever the request already asked for.
      def filter_field(predicate, label: nil, scope: nil)
        column = predicate.to_s.sub Search::LIST_PREDICATES, ''

        choice_filter(predicate, column, label) || reference_filter(predicate, column, label, scope)
      end

      # A menu of the records a foreign key points at. Nothing where that key is typed
      # rather than picked, which is the same question the field beside it asks: the
      # label is bounded, or the table is too long to list. Either way the menu would
      # be a table of its own. A `scope:` draws one anyway.
      def reference_filter(predicate, column, label, scope)
        association = belongs_to_association column
        return if association.nil? ||
                  (scope.nil? && association.klass.recourse_typed_reference?)

        filter_combobox predicate, label || reference_title(column, association),
                        (scope || association.klass).all
      end

      def filter_combobox(predicate, title, recourses)
        label = recourses.klass.recourse_label
        counter = filter_counter recourses.klass
        # What it reads as when nothing is ticked, so the way back is a line in the menu.
        models = Recourse.model_title recourses.klass, lower: true

        filter_menu predicate, title, nil, t('recourse.all', models: models),
                    label: label.to_s, counter: counter,
                    recourses: filter_options(recourses, label, counter)
      end

      # The commonest choice first where the model keeps a count, since a menu is read
      # from the top and most requests want the option most rows are behind — and by
      # name where it keeps none. The name breaks ties, or two markets on the same
      # number would swap places between one request and the next.
      def filter_options(recourses, label, counter)
        return recourses.select(:id, label).order label unless counter

        recourses.select(:id, label, counter).order counter => :desc, label => :asc
      end

      # The column on the model a filter lists that counts the rows being filtered —
      # `markets.zips_count` on `/zips`. Read from the counter caches that model keeps
      # rather than from a column named after this one, so a `zips_count` nobody
      # maintains is not a count. None on a nested page: the count is of every row in
      # the table, and the page shows the parent's share of them, which nothing counted.
      def filter_counter(klass)
        return if resource_parent

        klass.recourse_counters.find { |_, one| one.klass == resource_model }&.first
      end

      # Never invalid and never required: a filter narrows rather than sets.
      def filter_menu(predicate, title, values, all, **)
        render('recourses/combobox', name: "q[#{predicate}]", id: "q_#{predicate}",
                                     placeholder: title, multiple: true, aria_label: title,
                                     selected: filter_values(predicate), small: true,
                                     all: all, values: Array(values), **)
      end

      # A multiple combobox submits one comma-joined input, read back out the same way.
      def filter_values(predicate)
        query_params[predicate].to_s.split ','
      end
    end
  end
end
