module Recourse
  module Helpers
    # The week a table of events is read as: the seven days across it, the hours down
    # it, and the way out of one week into the next.
    module Calendars
      # How tall one hour of the grid stands. In `rem`, so a reader's own text size
      # takes the grid with it, and stated here because the arithmetic that places a
      # row against it is the gem's own — the stylesheet is told the answer.
      HOUR_HEIGHT = '3rem'

      # The hours a week with nothing in it draws: a working day, which is what a
      # reader moving through empty weeks has to place the next one's rows against.
      DEFAULT_HOURS = (8...18)

    private

      # The seven days the grid draws, Sunday first.
      def calendar_days(week) = week..(week + 6)

      # A day's heading, `Sun 13`, and today's said louder — the one column a reader
      # is looking for before they read a single row.
      def calendar_day_title(day)
        tag.span l(day, format: :recourse_day),
                 class: day == Time.zone.today ? 'fw-semibold' : 'fg-2'
      end

      # The hours the grid runs between, one row of the week each. Remembered per
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

      # One band of the grid, in the gutter and in every column, so a label and the
      # line it names stand at the same height.
      def calendar_hour_style = "height: #{HOUR_HEIGHT}"

      # The week the grid draws, read as the two days it runs between.
      def week_title(week)
        t 'recourse.week', from: l(week, format: :recourse), to: l(week + 6, format: :recourse)
      end

      # The three ways out of a week, drawn in the pagination a table's pages are
      # drawn in: the one before, this one, and the one after.
      def week_links(week)
        current = Recourse.week_of Time.zone.today

        safe_join [
          week_link(week - 1.week, 'recourse.previous_week'),
          this_week_link(current, week),
          week_link(week + 1.week, 'recourse.next_week'),
        ]
      end

      # A word rather than a link while this week is the week showing: a page offers
      # no address for the page it is already on.
      def this_week_link(current, week)
        return week_link current, 'recourse.this_week' unless current == week

        tag.li tag.span(t('recourse.this_week'), class: 'page-link'),
               class: 'page-item active', aria: { current: :page }
      end

      # Another week at this page's own address, the query going with it — so a search
      # or a filter stands while the weeks move under it.
      def week_link(week, key)
        query = request.query_parameters.merge week: week.to_s

        tag.li link_to(t(key), url_for(query.merge(format: :cal)), class: 'page-link'),
               class: 'page-item'
      end
    end
  end
end
