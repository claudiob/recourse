module Recourse
  module Helpers
    # The switch under a table saying how much of it one page shows.
    module Limits
    private

      # It names the size it is not showing, since the sentence beside it already says
      # how much of the table is on the page: what is left to say is where a click
      # goes. A button rather than a link — it performs something rather than leading
      # anywhere, and there is no address for a size the query string is not asked for.
      def limit_link(pagy)
        tag.button limit_label(other_limit(pagy)),
                   type: :button, data: { action: 'limit#toggle' },
                   class: 'btn btn-link btn-sm p-0 align-baseline recourse-limit'
      end

      # Two sizes, so the other one is the whole of the choice.
      def other_limit(pagy)
        (Recourse::LIMITS - [pagy.limit]).first
      end

      def limit_label(limit)
        t 'recourse.per_page', limit: limit
      end

      # What the switch behind the button needs: where to keep the choice, and the one
      # size a click writes there. Worked out here rather than in the browser, so the
      # page and the cookie can only ever agree.
      def limit_data(pagy)
        {
          controller: 'limit', limit_storage_value: Recourse::LIMIT_STORAGE,
          limit_to_value: other_limit(pagy),
        }
      end
    end
  end
end
