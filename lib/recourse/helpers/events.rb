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

      # One row, placed by the hours it runs between and saying what it is.
      def event_chip(recourse, hours, lane, lanes)
        tag.div event_words(recourse),
                class: 'position-absolute overflow-hidden small rounded border bg-1 px-1',
                style: event_style(recourse, hours, lane, lanes)
      end

      # What it says, a line each: its own label, whoever it is for, and the hours. In
      # that order because a chip is as tall as the row is long — an hour at the foot of
      # a full week is two lines — so what is clipped first is what the grid itself has
      # already said.
      def event_words(recourse)
        label = led Recourse.record_title(recourse), resource_model.name, recourse.id
        named = event_references recourse

        safe_join [
          tag.div(label, class: 'text-truncate'),
          named && tag.div(named, class: 'fg-2 text-truncate'),
          tag.div(event_times(recourse), class: 'fg-2 text-truncate'),
        ].compact
      end

      # Whoever the row points at, each led to its own page: a shift is read as whose
      # it is after it is read as what it is. Every `belongs_to` the model can follow,
      # and the same label a table's own cell would draw for it — already loaded, since
      # the index eager-loads every one of them.
      def event_references(recourse)
        named = resource_model.recourse_references.filter_map do |association|
          named_cell recourse, association
        end

        safe_join named, ' · ' if named.any?
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
