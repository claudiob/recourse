module Recourse
  module Helpers
    # The button that deletes the record a form is showing, and the warning it puts
    # in front of whoever clicked it.
    module Deletions
    private

      # The record a page may delete: the one it is about, on its own look or its own
      # change page. A nested index wears the parent's card and deletes nothing from it.
      # @api private
      def destroyable_record
        resource_record if controller.action_name.in? %w[show edit]
      end

      # Deletes the record on the page, or nothing at all where no action is routed
      # to delete it with — the same two guards the edit link answers to.
      # @api private
      def destroy_resource_button(record)
        path = record && destroy_resource_path(record)
        return unless path

        confirm_button_to destroy_label(record), path,
                          confirm: destroy_warning(record), method: :delete,
                          class: 'btn btn-sm btn-solid theme-danger ms-3',
                          form_class: 'd-inline-block'
      end

      # The word on the button, and below it the word over the dialog. A model that
      # undoes something rather than deleting it says so under its own name, and every
      # other model falls through to the one word the gem has. Keyed off the record's
      # class rather than the resource's, so a subclass words it apart from its
      # siblings: an integration a provider authorized is disconnected where the one an
      # admin picked is given up.
      def destroy_label(record)
        t worded(record, :delete), model: resource_name, default: :'recourse.delete'
      end

      def destroy_heading(record)
        t worded(record, :deletion_title), record: destroy_title(record),
                                           default: :'recourse.deletion.title'
      end

      # A slash in the key is a nesting to i18n, which is what lets a subclass sit
      # under the model it inherits from rather than beside it.
      def worded(record, name)
        :"recourse.models.#{record.model_name.i18n_key}.#{name}"
      end

      def destroy_resource_path(record)
        return unless routed_action? 'destroy'

        url_for action: :destroy, id: record
      end
    end
  end
end
