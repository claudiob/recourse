module Recourse
  module Routes
    # What the routes file is not allowed to say, said back to whoever wrote it while
    # the routes draw rather than answered with a broken page later.
    module Refusals
    private

      # The two that mean nothing without a page listing rows: a row is dragged from the
      # table that lists it, and a button fetching them again stands on that same table.
      # The retrieval is recorded here too, where a helper reads it back.
      def refuse_unindexed(names, positioned, fetched, options)
        refuse_unlisted names, 'unindexed', options if positioned
        refuse_unlisted names, 'unretrieved', options if fetched
        names.each { |name| Recourse.retrieve declared_path(name) } if fetched

        options
      end

      def refuse_unlisted(names, word, options)
        return if indexed? options

        raise Error, I18n.t("recourse.#{word}", names: names.map(&:inspect).join(', '))
      end

      def refuse_unscoped_nesting(names)
        parent = parent_resource
        return if parent.nil? || current_module.to_s.split('/').include?(parent.name)

        raise Error, I18n.t('recourse.nested', names: names.map(&:inspect).join(', '),
                                               parent: parent.name)
      end
    end
  end
end
