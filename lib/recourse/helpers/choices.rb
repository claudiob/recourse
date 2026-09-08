module Recourse
  module Helpers
    # The filter menus whose options are values rather than records: what a column
    # itself admits, read off the model rather than out of another table.
    module Choices
    private

      # The values a column admits of itself, where it admits a known set of them:
      # an enum's words, or a boolean's two. Nil for anything else, which is what
      # hands the question on to the key it might be.
      def choice_filter(predicate, column, label)
        return enum_filter predicate, column, label if resource_model.defined_enums.key? column

        boolean_filter predicate, column, label if boolean_column? column
      end

      # The two a boolean admits, as the words a table already prints for them. The
      # way back is the bare `All`: a column called `signed` pluralizes to nothing
      # anybody would write, so the line says what it does rather than what it is of.
      def boolean_filter(predicate, column, label)
        title = label || resource_model.human_attribute_name(column)

        filter_menu predicate, title, %w[true false], t('recourse.all_values')
      end

      def boolean_column?(column)
        resource_model.column_names.include?(column) &&
          resource_model.type_for_attribute(column).type == :boolean
      end

      # A menu of the words the column admits, which are the words the form's own menu
      # offers and the badge on a show page reads. Headed by the attribute rather than
      # by a model, since a status is the table's own and not another table's.
      def enum_filter(predicate, column, label)
        title = label || resource_model.human_attribute_name(column)
        values = resource_model.defined_enums[column].keys

        filter_menu predicate, title, values, choices_all(title)
      end

      # The way back to no filter at all, named after what the menu is of: `All
      # statuses`, `All CRMs`. An acronym keeps its capitals, the way every title
      # the gem lower-cases does.
      def choices_all(title)
        t 'recourse.all', models: Recourse.downcase(title).pluralize
      end
    end
  end
end
