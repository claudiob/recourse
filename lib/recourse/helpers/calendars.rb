module Recourse
  module Helpers
    # The grid a table of events is read as: the seven days across it, the hours down
    # it, and how tall the whole of it stands. What the week is called is `Weeks`.
    module Calendars
      # The hours a week with nothing in it draws: a working day, which is what a
      # reader moving through empty weeks has to place the next one's rows against.
      DEFAULT_HOURS = (8...18)

    private

      # The seven days the grid draws, Sunday first.
      def calendar_days(week) = week..(week + 6)

      # A day's heading, `Sun, Aug 30`, and today's said louder — the one column a reader
      # is looking for before they read a single row.
      def calendar_day_title(day)
        tag.span l(day, format: :recourse_day),
                 class: day == Time.zone.today ? 'fw-semibold' : 'fg-2'
      end

      # How tall the grid stands, whatever hours it draws, and why the figure is stated
      # here: a table's own first page is `LIMITS.first` rows, so a grid that height
      # leaves the weeks under a calendar where the pages under a table already are. A
      # row is its line box, the two paddings a cell keeps — Bootstrap's
      # `--bs-table-cell-padding-y`, which is declared inside a table and nowhere a
      # calendar could read it — and the rule under it.
      def calendar_grid_style
        "height: calc(#{Recourse::LIMITS.first} * (1em * var(--bs-body-line-height) + " \
          '1rem + var(--bs-border-width)))'
      end

      # The hours the grid runs between, one band of that height each. Remembered per
      # render: every one of the eight columns asks, and a page draws one grid.
      def calendar_hours(recourses)
        @recourse_hours ||= hours_of recourses
      end

      # From the hour the week's earliest row opens in to the one its latest closes
      # in, so a week of evenings is a grid of evenings rather than a day of empty
      # bands. `blank?` and not `empty?`: the rows are about to be drawn either way.
      def hours_of(recourses)
        return DEFAULT_HOURS if recourses.blank?

        minutes = recourses.map { |one| event_minutes one }

        (minutes.map(&:first).min / 60)...(minutes.map(&:last).max / 60.0).ceil
      end

      # An hour of the scale, `9am`, read off a clock rather than named in Ruby: which
      # words those are is a locale's to say, like every other time on the page.
      def calendar_hour_title(hour) = l(Time.zone.now.change(hour:), format: :recourse_hour)
    end
  end
end
