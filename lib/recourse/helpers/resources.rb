module Recourse
  module Helpers
    # What the page is about and what it is called: the model behind it, the record
    # on it, and the words both are read out under.
    module Resources
      # Where Ruby's own `to_s` lives: a record whose model never wrote one prints the
      # object's address, which is no name for a page.
      DEFAULT_PRINTERS = [Kernel, Object].freeze

      # Human, plural name of the resource on the page, e.g. `Contacts`. A page of
      # attachments is named after what the record calls them rather than after Active
      # Storage's own word for the row: `Photos`, never `Blobs`. `known_title`, since a
      # host page wearing this layout may be named after no model at all — a contact's
      # home is a `Location`, and the path is the only word for it.
      def resources_name
        return controller.controller_name.humanize if blob_resource?

        Recourse.known_title controller.controller_name
      end

      # Singular, lowercase name of the resource, e.g. 'contact' — and 'photo' on a page
      # of files, for the same reason as above.
      def resource_name
        return Recourse.downcase controller.controller_name.singularize.humanize if blob_resource?

        Recourse.downcase resource_model.model_name.human
      end

      # Local name a row partial receives its record under, e.g. :contact.
      def resource_key
        controller.controller_name.singularize.to_sym
      end

      # The record the action built, read from the assigns rather than by ivar name.
      def resource_record
        controller_assign resource_key.to_s
      end

      # The one door to what the controller assigned. `view_assigns` is public API,
      # and every name the gem reads through it walks this method, so the untyped
      # contract with the controller's ivar names has a single seam.
      def controller_assign(name)
        controller.view_assigns[name]
      end

      # What the record on the page is called, by whatever its model labels it with —
      # and nothing where there is no record to name.
      def resource_record_label
        return unless resource_record

        labelled_record.presence || printed_record
      end

    private

      # The column the model labels itself by, which most models keep.
      def labelled_record
        resource_record.attributes[resource_model.recourse_label.to_s]
      end

      # And what the record prints itself as, for the models that keep no such column:
      # a chat is called by the first thing asked in it, which no column holds. Only
      # where the model wrote a `to_s` of its own — the one Ruby supplies prints the
      # object's address, which names nothing and is worse than an unnamed crumb.
      def printed_record
        resource_record.to_s unless DEFAULT_PRINTERS.include? resource_record.method(:to_s).owner
      end

      # Resolved by the controller, which is the one that knows whether the name is a
      # model of this app's, something a record has attached, or a model a host named.
      def resource_model
        controller_assign('recourse_model') || Recourse.model(controller.controller_name)
      end
    end
  end
end
