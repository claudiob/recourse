module Recourse
  module Helpers
    # What one record reads as, laid out where its form's fields would be.
    module Values
    private

      # One labelled value in the show page's grid: the heading the table gives the
      # column, and under it what the record says, formatted the way the table's cell
      # for the same column is — this page reads a record out, so it names its columns
      # the way the page of every record does. `label:` overrides the heading.
      def value(name, **options)
        column = name.to_s
        label = options.fetch :label, resource_column_title(column)

        tag.div class: ROW do
          safe_join [tag.div(label, class: 'form-label'), value_control(column)]
        end
      end

      # What the record says for one column, or a dash where it says nothing. A
      # boolean says something either way, and an icon says it, so only a value that
      # formats to nothing at all reads as nothing.
      def resource_value(column)
        value = formatted_value column

        value.to_s.empty? ? t('recourse.blank') : value
      end

      # Nothing to disclose is nothing to mask: an encrypted column the record has no
      # value for reads as the dash, rather than as one asterisk hiding one.
      def value_control(column)
        return masked_value formatted_value(column) if masked? column

        tag.div resource_value(column), class: 'form-control-plaintext'
      end

      def masked?(column)
        encrypted_column?(column) && resource_record.attributes[column].present?
      end

      # PII is a page's to show and nobody's to leak by accident, so it arrives as one
      # asterisk per character with the plaintext in an attribute the reveal reads: a
      # screenshot of the page discloses nothing, and reading one value takes a click.
      def masked_value(value)
        options = {
          class: 'form-control-plaintext d-flex gap-2 align-items-end',
          data: { controller: 'reveal', reveal_plain_value: value },
        }

        tag.div(**options) { safe_join [masked_span(value), reveal_button] }
      end

      def masked_span(value)
        tag.span '*' * value.length, data: { reveal_target: 'mask' }
      end

      def reveal_button
        tag.button t('recourse.reveal'), type: :button,
                                         class: 'btn btn-link btn-sm p-0',
                                         data: { action: 'reveal#show', reveal_target: 'button' }
      end
    end
  end
end
