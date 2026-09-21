module Recourse
  module Helpers
    # The menus beside a search box: one per foreign key a table can be narrowed by,
    # and one per list of words a host named itself.
    module Filters
    private

      # The filters this page draws, as the markup each one is. A declared filter
      # that draws nothing falls out here — a foreign key whose label is typed
      # rather than picked — so what is left is what a form would hold, which is
      # what decides whether there is a form at all.
      def resource_filter_fields
        resource_filters.filter_map { |predicate| filter_field predicate }
      end

      # The model's filters, less the one a nested route already answered:
      # /markets/1/sectors is filtered by market_id in the URL itself, and a menu
      # for it would only offer to re-ask — or to contradict — the address.
      def resource_filters
        parent = resource_parent_association
        filters = declared_filters
        return filters unless parent

        filters - ["#{parent.foreign_key}_in"]
      end

      # The predicates the model named, as words. A filter is named and nothing else:
      # what it reads as and what it offers are the column's to say.
      def declared_filters
        resource_model.filter_fields.map(&:to_s)
      end

      # One filter: the values a column of its own admits, a menu of the records a
      # foreign key points at, or one reached through an association. A predicate
      # Ransack will not answer is refused here rather than drawn, a menu that
      # narrows nothing being worse than no menu at all.
      def filter_field(predicate)
        refuse_unanswerable predicate
        column = predicate.sub Search::LIST_PREDICATES, ''

        choice_filter(predicate, column) || reference_filter(predicate, column) ||
          reached_filter(predicate, column)
      end

      # Ransack decides, since Ransack is what would drop it: a model answers for the
      # attributes it allows and no others, and a filter naming one it does not allow
      # comes back holding every row.
      def refuse_unanswerable(predicate)
        resource_model.ransack({ predicate => ['1'] }, ignore_unknown_conditions: false)
      rescue ::Ransack::InvalidSearchError
        raise Error, I18n.t('recourse.unanswerable', model: resource_model, predicate:)
      end

      # A menu of the records a foreign key points at. Nothing where that key is typed
      # rather than picked, which is the same question the field beside it asks: the
      # label is bounded, or the table is too long to list. Either way the menu would
      # be a table of its own.
      def reference_filter(predicate, column)
        association = belongs_to_association column
        return if association.nil? || association.klass.recourse_typed_reference?

        filter_combobox predicate, reference_title(column, association), association.klass.all
      end
    end
  end
end
