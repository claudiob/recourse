module Recourse
  module Helpers
    # What a calendar draws of one row: the lane it is given where a day's rows overlap,
    # and what it says once it has one. Where it is placed is `Spans`.
    module Events
    private

      # One day's rows, in the lanes that day needed: a row takes the first lane whose
      # last row has closed, so rows that overlap stand side by side. The lanes are
      # counted over the whole day rather than over each run of overlaps — a column is
      # a day, and two days are read against each other.
      def calendar_events(recourses, day, hours)
        lanes = []
        placed = recourses.select { |one| opens_on? one, day }
                          .map { |one| [one, take_lane(one, lanes)] }

        safe_join(placed.map { |one, lane| event_chip one, hours, lane, lanes.size })
      end

      def opens_on?(recourse, day) = recourse.attributes[Recourse::START_COLUMN].to_date == day

      # The first lane free by the time this row opens, or one of its own, with the
      # minute it closes at left in it for whatever comes next.
      def take_lane(recourse, lanes)
        opening, closing = event_minutes recourse
        lane = lanes.index { |taken| taken <= opening } || lanes.size
        lanes[lane] = closing

        lane
      end

      # What one row says: its own label over the hours it runs between, and its page
      # behind the label where the routes drew one.
      def event_chip(recourse, hours, lane, lanes)
        label = led Recourse.record_title(recourse), resource_model.name, recourse.id
        said = safe_join [
          tag.div(label, class: 'text-truncate'),
          tag.div(event_times(recourse), class: 'fg-2 text-truncate'),
        ]

        tag.div said, class: 'position-absolute overflow-hidden small rounded border bg-1 px-1',
                      style: event_style(recourse, hours, lane, lanes)
      end

      # The two ends of a row, each carrying what a machine reads, like every other
      # time on these pages.
      def event_times(recourse)
        ends = Recourse::EVENT_COLUMNS.filter_map do |column|
          value = recourse.attributes[column]

          time_tag value, l(value, format: :recourse_time) if value
        end

        safe_join ends, '–'
      end
    end
  end
end
