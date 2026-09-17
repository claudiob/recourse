module Recourse
  # Which week a calendar draws, and the rows that fall inside it.
  module Weeks
    # How a week is written into an address: `?week=2026-09-13`, any day of the one
    # meant, since a reader following a link never types one.
    WEEK_FORMAT = '%Y-%m-%d'

  private

    # The Sunday the calendar opens on: the week the address names, or the reader's
    # own. An address is a stranger's to write, so a day nothing can be made of is
    # this week rather than a 500.
    def recourse_week
      Recourse.week_of Date.strptime(params[:week].to_s, WEEK_FORMAT)
    rescue Date::Error
      Recourse.week_of Time.zone.today
    end

    # What the index lists, as the pair it assigns: one week where the calendar was
    # asked for, and one page everywhere else. A calendar has no pages to take and a
    # table has no week, so neither shape carries the other's.
    def week_or_page(scope)
      return pagy scope, limit: recourse_limit unless request.format.cal?

      [nil, week_resources(scope)]
    end

    # The week's rows, earliest first and all of them: a week is how much a calendar
    # shows, so the sort a heading asked for is not what a grid reads by. Against the
    # reader's own clock, which `Zoning` has already put in `Time.zone` — the same
    # midnight the grid draws from.
    def week_resources(scope)
      @recourse_week = recourse_week
      opening = @recourse_week.in_time_zone

      scope.reorder(Recourse::START_COLUMN => :asc)
           .where Recourse::START_COLUMN => opening...(opening + 1.week)
    end
  end
end
