module Recourse
  module Helpers
    # What a value is drawn behind when it is worth more room than a page will give it
    # unasked: closed to begin with, so a column of values stays a column of values.
    module Details
    private

      # The shape itself, said once: what the thing is, and the thing under it. A
      # picture and a list are both this, and neither should be spelling it out.
      def detailed(summary, body)
        tag.details { safe_join [tag.summary(summary), body] }
      end

      # A list reads as how many first — the values are what opening it is for — and
      # then as the values themselves. Nil rather than an empty `<details>` where there
      # is nothing in it, so an empty list reads as the dash every other empty value
      # reads as rather than as a summary with nothing behind it.
      def listed(values)
        count = listed_count values
        return unless count

        detailed count, listed_items(values)
      end

      # How many a list holds, and nothing else: what a table shows in place of the
      # values, and what the summary above reads before anybody opens it. Nil for an
      # empty one, which reads as blank in a cell and as the dash on a record's page.
      def listed_count(values)
        return if values.blank?

        t 'recourse.items', count: values.size
      end

      # `mb-0`, because the row below it draws the rule between them and a list's own
      # bottom margin would push that rule away from the values it closes.
      def listed_items(values)
        tag.ul safe_join(values.map { |one| tag.li one }), class: 'mb-0 mt-2'
      end
    end
  end
end
