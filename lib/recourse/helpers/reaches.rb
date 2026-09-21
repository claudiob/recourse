module Recourse
  module Helpers
    # A filter that reaches through an association: `skilled_specialties_id_in` on a
    # provider names the specialties it is skilled in, and `integration_type_in` the
    # CRM its integration is. The predicate says which association and which of its
    # columns, and the column says what the menu is of.
    module Reaches
    private

      # A menu for a column on another model, where the predicate names the way there.
      # The rows a key points at, or the kinds a table holds where the column is the
      # one Rails keeps a subclass in, or whatever else that column holds.
      def reached_filter(predicate, column)
        association, attribute = reached_association column
        return unless association

        klass = association.klass
        title = klass.model_name.human
        return rows_filter predicate, title, klass if attribute == klass.primary_key

        held_filter predicate, title, klass, attribute
      end

      # Every row of the other table, unless it is too long to be a menu — the same
      # question a key pointing at it answers, since a menu of forty thousand buttons
      # is a table wearing the wrong clothes.
      def rows_filter(predicate, title, klass)
        filter_combobox predicate, title, klass.all unless klass.recourse_typed_reference?
      end

      # The association a column reaches through, and what is left of the column once
      # its name is taken off. The longest name wins, so `listed_contact_id` reaches
      # through `listed_contact` rather than through a `listed` beside it.
      def reached_association(column)
        named = resource_model.reflect_on_all_associations.select do |one|
          column.start_with? "#{one.name}_"
        end
        one = named.max_by { |association| association.name.length }

        [one, column.delete_prefix("#{one.name}_")] if one
      end

      # The values a column on the other table holds, read from the rows rather than
      # from anywhere they are declared: a value nobody has written is a filter that
      # would answer nothing, and a column holding more of them than a menu takes is a
      # table wearing the wrong clothes.
      def held_filter(predicate, title, klass, attribute)
        return unless klass.column_names.include? attribute

        held = klass.distinct.limit(Searchable::MENU_LIMIT + 1).pluck(attribute).compact.sort
        return if held.empty? || held.size > Searchable::MENU_LIMIT

        values_filter(predicate, title, held.map { |one| [held_title(klass, attribute, one), one] })
      end

      # What one of them reads as: the word itself, unless the column is the one Rails
      # keeps a subclass in, where it reads as the locale calls that model — the key
      # Rails writes a subclass under, so no class is named to find it.
      def held_title(klass, attribute, value)
        return value unless attribute == klass.inheritance_column

        t "activerecord.models.#{value.underscore}", default: value.demodulize.titleize
      end
    end
  end
end
