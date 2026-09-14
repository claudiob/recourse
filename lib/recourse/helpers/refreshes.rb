module Recourse
  module Helpers
    # Subscribes an index page to the refreshes its model broadcasts.
    module Refreshes
    private

      # The subscription tag, and nothing at all when the model broadcasts nothing, so a page
      # never listens for what will not come. The layout's head has the two metas that make
      # a refresh morph in place and keep the scroll.
      def refresh_subscription
        return unless resource_model.recourse_broadcasting?

        turbo_stream_from resource_model.model_name.plural
      end
    end
  end
end
