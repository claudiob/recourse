module Recourse
  module Helpers
    # The field a form offers for putting a file on a record, and the note under it
    # saying what the record is holding already.
    module Attachments
    private

      # The attachments this screen's model keeps, which the form draws after every
      # column it has: a file input is the widest control on the page.
      def attachment_names
        Recourse.attachment_names resource_model
      end

      # One labelled file input, in the grid a column's field sits in. `multiple` where
      # the model keeps several, and no hidden blank beside it: nothing here is ever
      # assigned, so a field nobody touched is one the write passes over.
      def attachment_field(name)
        label = resource_model.human_attribute_name name

        tag.div class: ROW do
          safe_join [
            @recourse_form.label(name, label, class: 'form-label'),
            @recourse_form.file_field(name, **attachment_options(name)),
            attached_note(name),
          ].compact
        end
      end

      # A file input carries none of a column's constraints, so its options are the
      # class, the note under it, and whether it takes several files at once.
      def attachment_options(name)
        described = field_note_id name if resource_record&.persisted?
        options = { class: 'form-control', aria: { describedby: described } }
        return options unless Recourse.attachment_many? resource_model, name

        options.merge multiple: true, include_hidden: false
      end

      # What the record is holding, under the field that adds to it: choosing a file
      # joins what is there or replaces it, and which of the two it is depends on what
      # is there. Only where there is a record to ask — a form making one has nothing
      # attached yet, so it has nothing to report and says nothing.
      def attached_note(name)
        return unless resource_record&.persisted?

        field_note attached_reading(name), field_note_id(name)
      end

      def attached_reading(name)
        files = attached_filenames name
        return attached_nothing name if files.empty?
        return t 'recourse.attached.one', files: files.first if files.one?

        t 'recourse.attached.many', count: files.size, files: files.to_sentence
      end

      # A field for one file reads `No file attached` where a field for several reads
      # `No files attached`, since which it is decides what choosing one will do.
      def attached_nothing(name)
        many = Recourse.attachment_many? resource_model, name

        t "recourse.attached.#{many ? 'none_many' : 'none'}"
      end
    end
  end
end
