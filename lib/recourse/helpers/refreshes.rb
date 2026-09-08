module Recourse
  module Helpers
    # Subscribes an index page to the refreshes its model broadcasts.
    module Refreshes
    private

      # The subscription tag, after asking the head for the two metas that make a
      # refresh morph in place and keep the scroll — and nothing at all when the
      # model broadcasts nothing, so a host without turbo-rails is untouched.
      def refresh_subscription
        return unless resource_model.recourse_broadcasting?

        content_for :head, refresh_metas
        turbo_stream_from resource_model.model_name.plural
      end

      # Without these Turbo answers a refresh by replacing the whole body, which
      # drops the caret, the scroll and any menu that was open.
      def refresh_metas
        safe_join [
          tag.meta(name: 'turbo-refresh-method', content: 'morph'),
          tag.meta(name: 'turbo-refresh-scroll', content: 'preserve'),
        ]
      end
    end
  end
end
