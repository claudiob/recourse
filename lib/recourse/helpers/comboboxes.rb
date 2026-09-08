module Recourse
  module Helpers
    # The menu a foreign key offers when its label is too long to be typed.
    module Comboboxes
    private

      # A combobox of labels. The query fetches the two columns the menu shows and
      # nothing else, and the errors are its own work: `field_error_proc` only ever
      # sees the tags a form builder drew, and this is a partial.
      def combobox(form, column, association)
        label = association.klass.recourse_label

        render 'recourses/combobox', **combobox_locals(form, column),
                                     label: label.to_s,
                                     recourses: combobox_options(association.klass, label)
      end

      # Whichever menu a kind whose values are known in advance is drawn as.
      def menu_field(form, column, kind)
        kind == :enum ? enum_combobox(form, column) : zone_combobox(form, column)
      end

      # The words an enum admits, as a menu of one. The values are the model's own, so
      # nothing here has to know what any of them mean.
      def enum_combobox(form, column)
        render 'recourses/combobox', **combobox_locals(form, column),
                                     values: resource_model.defined_enums[column].keys,
                                     selected: [form.object.attributes[column]].compact
      end

      # Whether a menu's rows can be kept, which turns on the one thing a relation is
      # versioned by: `cache` reads `MAX(updated_at)` off the table without asking
      # whether there is such a column, and a model Rails keeps no timestamps on has
      # none to read. Reference data is exactly where that happens — a table of states
      # or of postal codes is written by a migration and never again — so those menus
      # are drawn each time rather than kept under a key nothing can version.
      def keepable_menu?(recourses)
        recourses.klass.column_names.include? 'updated_at'
      end

      # What every combobox needs to know about the column it sets, whatever it offers
      # as choices: the enum one asks for these too, and gives `values:` instead.
      def combobox_locals(form, column)
        messages = errors_on column
        required = required? resource_model, column

        {
          name: form.field_name(column), id: form.field_id(column), invalid: messages.any?,
          feedback: messages.to_sentence.upcase_first.presence,
          described: combobox_described(form, column, messages),
          placeholder: combobox_placeholder(column), required: required,
          # A menu of records can say which one; only this can say none of them, and
          # a key that may be nothing has to be settable back to it.
          none: (t 'recourse.unset' unless required),
          selected: combobox_selected(form, column),
        }
      end

      # What the toggle points at: its own error where it has one, and otherwise the
      # note under it. The same order of precedence every other control follows.
      def combobox_described(form, column, messages)
        id = form.field_id column
        return "#{id}_error" if messages.any?

        field_described column
      end

      # What the record already holds, as the menu spells its values: an id for a
      # foreign key and the word itself for an enum. Without it a form opens on the
      # placeholder however full the record is — and the plugin's hidden input opens
      # empty with it, so saving would write that emptiness back.
      def combobox_selected(form, column)
        value = form.object&.attributes&.fetch column.to_s, nil

        Array(value).map(&:to_s)
      end

      def combobox_options(klass, label)
        klass.select(:id, label).order label
      end

      def combobox_placeholder(column)
        placeholder(resource_model, column, nil) || t('recourse.select')
      end
    end
  end
end
