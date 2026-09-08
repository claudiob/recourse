module Recourse
  module Helpers
    # The button that deletes the record a form is showing, and the warning it puts
    # in front of whoever clicked it.
    module Deletions
      # `dependent:` values that take the children with the parent.
      DESTROYED = %i[destroy destroy_async].freeze

      # And the one that keeps them, holding the key open. Anything else — a bare
      # `has_many`, a `:restrict` — is left unsaid rather than guessed at.
      NULLIFIED = %i[nullify].freeze

    private

      # Deletes the record on the page, or nothing at all where no action is routed
      # to delete it with — the same two guards the edit link answers to.
      def destroy_resource_button(record)
        path = destroy_resource_path record
        return unless path

        options = {
          method: :delete, class: 'btn btn-sm btn-solid theme-danger ms-3',
          form_class: 'd-inline-block', data: { turbo_confirm: destroy_warning(record) },
        }

        button_to t('recourse.delete', model: resource_name), path, **options
      end

      # What deleting this record takes with it, counted a level down and no further:
      # a state reaches counties, then ZIPs, then locations, and counting that far
      # would join 40,965 rows to draw one page.
      def destroy_warning(record)
        lines = [t('recourse.deletion.title', record: destroy_title(record)), nil]

        [*lines, *dependent_lines(record), nil, t('recourse.deletion.undone')].join "\n"
      end

      def destroy_resource_path(record)
        return unless routed_action? 'destroy'

        url_for action: :destroy, id: record
      end

      # The middle of the warning, in the order it reads: what goes, what stays, and
      # only then what is under what goes — the levels this stops short of counting.
      def dependent_lines(record)
        going = dependents record, DESTROYED
        staying = dependents record, NULLIFIED
        lines = []
        lines << t('recourse.deletion.going', list: going.to_sentence) if going.any?
        lines << staying_line(staying) if staying.any?
        lines << t('recourse.deletion.under') if going.any?

        lines
      end

      def staying_line(staying)
        t 'recourse.deletion.staying', list: staying.to_sentence, model: resource_name
      end

      def dependents(record, kinds)
        record.class.reflect_on_all_associations(:has_many).filter_map do |association|
          next if association.through_reflection || kinds.exclude?(association.options[:dependent])

          dependent_count record, association
        end
      end

      # `association.reader` rather than a method named at runtime, and `count` rather
      # than loading them: the warning needs how many, never which.
      def dependent_count(record, association)
        count = record.association(association.name).reader.count
        return if count.zero?

        name = Recourse.downcase association.klass.model_name.human

        "#{number_with_delimiter count} #{name.pluralize count}"
      end

      # What the record is called, or what it is, for one that answers to no label.
      def destroy_title(record)
        record.attributes[record.class.recourse_label.to_s].presence ||
          record.class.model_name.human
      end
    end
  end
end
