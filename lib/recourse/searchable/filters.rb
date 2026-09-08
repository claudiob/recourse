module Recourse
  module Searchable
    # What a model offers as a filter beside the search box: a menu for every column
    # whose values are a short known list, and one for every key pointing at a table
    # short enough to list.
    module Filters
      # Filters offered beside the search box, as a Ransack predicate to the options
      # that draw it — `label:` for its heading, `scope:` for the records it offers.
      # One per enum, one per boolean, then one per belongs_to, less the ones the
      # search box reaches through instead: a typed label says the other model is too
      # big to list. The model's own columns come first, before the menus that name
      # other tables.
      def filter_fields
        enum_filter_fields.merge(boolean_filter_fields).merge reference_filter_fields
      end

    private

      # Columns a filter may name at all. A menu narrowing the table by a column no
      # screen shows asks a reader to choose by something they cannot see, which is the
      # reason `recourse_searchable_columns` leaves the same columns out of the search
      # box: hidden from every screen means hidden here.
      def filterable_columns
        column_names - Recourse.hidden_columns(self)
      end

      # Every one of the three comes to the same shape, and `_in` is what lets a
      # request tick more than one of the values a menu offers.
      def filters_for(names)
        names.index_with({}).transform_keys { |name| "#{name}_in" }
      end

      # One per enum: a dozen words a column admits are a menu whatever else is on the
      # page.
      def enum_filter_fields
        filters_for defined_enums.keys & filterable_columns
      end

      # One per boolean: a column admitting two values is a menu for the same reason a
      # dozen words are, and the two are the type's own rather than anything declared.
      def boolean_filter_fields
        booleans = filterable_columns.select { |one| type_for_attribute(one).type == :boolean }

        filters_for booleans
      end

      # One per belongs_to the search box does not reach through instead.
      def reference_filter_fields
        searched = recourse_searchable_associations
        keys = recourse_references.filter_map do |one|
          one.foreign_key.to_s unless searched.include? one
        end

        filters_for keys & filterable_columns
      end
    end
  end
end
