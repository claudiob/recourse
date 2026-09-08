module Recourse
  module Helpers
    # A date or a time on a page that only reads it, drawn against the reader's own
    # clock — which is `Time.zone` here, because `Zoning` put it there.
    module Times
    private

      # In words and in the attribute a machine reads. `l` picks the date format or the
      # time one by what it is handed, so nothing here has to ask which it has — and a
      # `DateTime`, which is both, still keeps its time.
      def localized(kind, value)
        time_tag value, l(value, format: :recourse), **relative_naming(kind, value)
      end

      # Only an instant is told how far off it is. A date is a day and a time is a time
      # of day, and neither is a moment for `in 9 years` to count against. Beside the
      # value rather than above it, unlike the icons that head a column: a timestamp
      # has a row of the table above it and a value of its own page, and either is
      # something a reader may be comparing this one against.
      def relative_naming(kind, value)
        return {} unless kind == :datetime

        {
          data: {
            controller: 'relative-time tooltip', bs_placement: 'left',
            bs_title: relative_words(value),
          },
        }
      end

      # Rails says how far off, never which way, so the direction is supplied here — in
      # the wording `Intl.RelativeTimeFormat` uses, since the browser says these words
      # again on the way to the tooltip and two spellings of one phrase read as two.
      # It has to say them again: these are true when the page is drawn, and the page
      # may be cached for a day.
      def relative_words(value)
        key = value.past? ? 'recourse.ago' : 'recourse.from_now'

        t key, distance: distance_of_time_in_words_to_now(value)
      end
    end
  end
end
