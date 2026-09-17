module Recourse
  module Helpers
    # What a week is called, and the ways out of one into the next.
    module Weeks
      # The four ways out of a week, in the order they stand, each as the weeks it moves
      # and the arrow it is drawn as. The outer pair jump four weeks, which is a month as
      # near as a grid drawn in weeks can hold one.
      WEEK_STEPS = {
        previous_weeks: [-4, '<<'], previous_week: [-1, '<'],
        next_week: [1, '>'], next_weeks: [4, '>>'],
      }.freeze

    private

      # The week the grid draws, named as the two days it runs between: `September 13th
      # – September 19th, 2026`. The year is said once, at the end, being the one thing
      # the two ends of a week almost always agree about.
      def week_title(week)
        finish = week + 6

        t 'recourse.week', from: week_day(week), to: week_day(finish), year: finish.year
      end

      def week_day(day) = "#{l day, format: :recourse_month} #{day.day.ordinalize}"

      # The ways out of a week, drawn as a table's pages are drawn — pagy's own markup,
      # down to the arrows and to the item it leaves unlinked — with the week showing
      # named in the middle, where pagy names the page.
      def week_links(week)
        shown = tag.a week_title(week), role: :link, class: 'page-link',
                                        aria: { current: :page, disabled: true }

        safe_join [
          week_step(week, :previous_weeks), week_step(week, :previous_week),
          tag.li(shown, class: 'page-item active'),
          week_step(week, :next_week), week_step(week, :next_weeks),
        ]
      end

      # One step: its own arrow, and the words behind it for a reader who is hearing
      # the page rather than seeing it. The query goes with the week, so a search or a
      # filter stands while the weeks move under it.
      def week_step(week, key)
        weeks, arrow = WEEK_STEPS[key]
        query = request.query_parameters.merge week: (week + weeks.weeks).to_s
        step = link_to arrow, url_for(query.merge(format: :cal)),
                       class: 'page-link', aria: { label: t("recourse.#{key}") }

        tag.li step, class: "page-item #{weeks.negative? ? 'previous' : 'next'}"
      end
    end
  end
end
