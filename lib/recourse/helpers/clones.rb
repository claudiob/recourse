module Recourse
  module Helpers
    # The link a record's own page carries to a form filled in from it, and what that
    # form says about the parts of the record a field cannot show.
    module Clones
    private

      # A link rather than a button, and the navbar's dress for one: it opens a form to
      # fill in, and nothing is written until that form is submitted -- the same thing
      # `Add %{model}` is on an index, reached from a record instead of from a list.
      #
      # Only on the record's own page, which is the only page with one record to copy,
      # and only where there is a form to open. The routes are the whole check there,
      # exactly as they are for the Add link itself.
      def clone_resource_link(record)
        return unless record_page? && routed_action?('new')

        link_to t('recourse.clone'), url_for(action: :new, cloned_id: record.id),
                class: 'btn theme-primary btn-sm btn-outline ms-3'
      end

      # What a copy brings that the form above it cannot show: the fields are the
      # record's own columns, and everything `recourse_cloned` names comes along unseen.
      # Nothing at all for a model that names none, which leaves an ordinary form as it
      # was. The delete warning counts its children the same way and for the same
      # reason -- what a write is about to reach is worth reading before clicking.
      def cloned_note
        record = controller_assign 'recourse_clone_source'
        return unless record

        list = cloned_parts record
        return if list.empty?

        field_note t('recourse.cloned', list: list.to_sentence).upcase_first, nil
      end

      # One phrase per association named, counted where there is a number to count and
      # named where there is only ever one. `association.reader` rather than a method
      # worked out at runtime, the way the delete warning reaches its own.
      def cloned_parts(record)
        record.class.recourse_cloned.filter_map do |name|
          reflection = record.class.reflect_on_association name
          next cloned_file_part record, name unless reflection

          cloned_part record, reflection
        end
      end

      # `its audit` for the one a `has_one` holds -- one record is not a number, and
      # reads worse as `1 audit` -- and `3 notions` for a collection.
      def cloned_part(record, reflection)
        target = record.association(reflection.name).reader
        model = Recourse.downcase reflection.klass.model_name.human
        return cloned_one model, target if reflection.macro == :has_one

        cloned_count target.count, model
      end

      # And the files, counted through the association Active Storage names rather than
      # the record's own: what is carried is the blob, not the row pointing at it. Named
      # after the attachment rather than after `Blob`, since `3 photos` is what a reader
      # calls them and `3 blobs` is what Active Storage does.
      def cloned_file_part(record, name)
        many = Recourse.attachment_many? record.class, name.to_s
        blobs = record.association(many ? :"#{name}_blobs" : :"#{name}_blob").reader
        model = Recourse.downcase name.to_s.humanize.singularize

        many ? cloned_count(blobs.count, model) : cloned_one(model, blobs)
      end

      # `its floor plan`, and nothing where there is none: one of a thing is named
      # rather than counted, whether it is a record or a file.
      def cloned_one(model, target)
        t 'recourse.cloned_one', model: model if target
      end

      # Nothing at all where there are none to bring: a form should not offer to copy
      # an empty shelf.
      def cloned_count(count, model)
        return if count.zero?

        "#{number_with_delimiter count} #{model.pluralize count}"
      end
    end
  end
end
