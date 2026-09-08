module Recourse
  module Helpers
    # Chooses the form field a column deserves, and labels it.
    module Fields
    private

      # One labelled field in the form's grid. `label:` overrides the heading and
      # `type:` overrides the input the column would otherwise have chosen.
      def field(name, **options)
        column = name.to_s
        label = options.fetch :label, reference_title(column, belongs_to_association(column))

        tag.div class: ROW do
          safe_join [
            @recourse_form.label(column, label, class: 'form-label'),
            resource_field(@recourse_form, column, type: options[:type]),
            field_comment(column),
          ].compact
        end
      end

      # What the database says the column is for, under the field that sets it.
      def field_comment(column)
        field_note resource_model.recourse_comment(column), field_note_id(column)
      end

      # What the control points at, where it should point at anything. Only where there
      # is a note to point at — and only where the field has nothing more urgent to say,
      # since an error outranks a hint. `field_error_proc` is the host's and writes its
      # own `aria-describedby` for an invalid field, so rather than leave a second one
      # for the browser to throw away, this one stands down and says so here.
      def field_described(column)
        return if resource_model.recourse_comment(column).blank?
        return if errors_on(column).any?

        field_note_id column
      end

      # Named off the field's own id, the way Rails names everything else about it.
      def field_note_id(column)
        id = @recourse_form.field_id column

        "#{id}_help"
      end

      # The line under a field saying what somebody wants to know before filling it in:
      # what the column is for, or what the record already has attached. Both come
      # through here, so the two read as one kind of thing and how they read is settled
      # in one place. Nothing at all where there is nothing to say.
      #
      # `mt-1` because Bootstrap's `.form-text` declares `--bs-form-text-margin-top` and
      # never applies it; `.25rem` is what that variable holds, so this is the gap the
      # class already meant. `fg-secondary` for a line that answers a question nobody
      # asked — quieter than the value it sits under, and quieter than `.form-text`'s
      # own `--bs-fg-2`, which a utility later in the cascade is what overrides.
      def field_note(text, id)
        tag.div text, class: 'form-text mt-1 fg-secondary', id: id if text.present?
      end

      # A field typed by what the column holds, not merely a text box.
      def resource_field(form, column, type: nil)
        association = belongs_to_association column
        return reference_field form, column, association if association

        # Rails mirrors `maxlength` into `size`, which would shrink the box to it.
        aria = { describedby: field_described(column) }
        options = { class: 'form-control', size: nil, aria: }.merge field_html(column, type)

        return form.text_field column, **options, type: type if type
        return form.email_field column, **options if column == 'email'

        kind_field form, column, **options
      end

      def encrypted_column?(column)
        resource_model.recourse_encrypted_names.include? column
      end
    end
  end
end
