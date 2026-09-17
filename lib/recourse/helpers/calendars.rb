module Recourse
  module Helpers
    # The week a table of events is read as: the seven days across it, the hours down
    # it, and the way out of one week into the next.
    module Calendars
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

      # The week the grid draws, named as the two days it runs between: `September 13th
      # – September 19th, 2026`. The year is said once, at the end, being the one thing
      # the two ends of a week almost always agree about.
      def week_title(week)
        finish = week + 6

        t 'recourse.week', from: week_day(week), to: week_day(finish), year: finish.year
      end

      def week_day(day) = "#{l day, format: :recourse_month} #{day.day.ordinalize}"

      # The weeks either side, drawn as a table's pages are drawn — pagy's own markup,
      # down to the arrows and to the item it leaves unlinked — with the week showing
      # named between them, where pagy names the page.
      def week_links(week)
        shown = tag.a week_title(week), role: :link, class: 'page-link',
                                        aria: { current: :page, disabled: true }

        safe_join [
          week_step(week - 1.week, 'previous'),
          tag.li(shown, class: 'page-item active'),
          week_step(week + 1.week, 'next'),
        ]
      end

      # One step either way: pagy's own arrow, and the words behind it for a reader
      # who is hearing the page rather than seeing it. The query goes with the week,
      # so a search or a filter stands while the weeks move under it.
      def week_step(week, way)
        query = request.query_parameters.merge week: week.to_s
        arrow = way == 'previous' ? '<' : '>'
        step = link_to arrow, url_for(query.merge(format: :cal)),
                       class: 'page-link', aria: { label: t("recourse.#{way}_week") }

        tag.li step, class: "page-item #{way}"
      end
    end
  end
end
