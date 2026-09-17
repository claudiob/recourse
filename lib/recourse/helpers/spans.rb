module Recourse
  module Helpers
    # How much of a day one row takes, and where in the grid that puts it. Every figure
    # here is minutes on the way in and a share of the grid on the way out, so a row and
    # the hours behind it agree however tall an hour is drawn.
    module Spans
      # Minutes in a day, which is where a row running into the next one stops: a
      # calendar draws a row on the day it opens, and a block past the foot of its
      # column would be drawn over the week.
      DAY_MINUTES = 1440

      # And the least a row may be drawn as, so one nobody gave a length to is still
      # something to read and to click rather than a line.
      LEAST_MINUTES = 15

    private

      # Where the row sits: how far down the grid it opens, how much of the grid it
      # takes, and which lane of its day it was given.
      def event_style(recourse, hours, lane, lanes)
        width = 100.0 / lanes
        shares = event_shares(recourse, hours).merge left: lane * width, width: width

        shares.map { |side, share| "#{side}: #{share.round 2}%" }.join '; '
      end

      # The two the hours decide: everything above the row, and the row itself.
      def event_shares(recourse, hours)
        opening, closing = event_minutes recourse
        minutes = hours.count * 60.0

        {
          top: (opening - (hours.first * 60)) * 100 / minutes,
          height: (closing - opening) * 100 / minutes,
        }
      end

      # When a row opens and closes, as minutes from the midnight of the day it opens
      # on — the two figures every measurement above is made from.
      def event_minutes(recourse)
        opening = recourse.attributes[Recourse::START_COLUMN]
        opened = minute_of opening

        [opened, [closing_minute(opening, recourse), opened + LEAST_MINUTES].max]
      end

      # Midnight for a row that runs into the next day, and for one nothing has closed
      # yet — an end nobody has written is a row still open rather than one over at once.
      def closing_minute(opening, recourse)
        closing = recourse.attributes[Recourse::FINISH_COLUMN]
        return DAY_MINUTES if closing.nil? || closing.to_date != opening.to_date

        minute_of closing
      end

      def minute_of(value) = (value.hour * 60) + value.min
    end
  end
end
