module Recourse
  # How much of a table one page shows: pagy's twenty by default, or whatever the
  # reader picked from the menu under the table, kept in their own browser.
  module Paging
  private

    # Checked against the two we offer rather than taken as read — a cookie is a value
    # a stranger can write, and an unchecked one is `?limit=100000` by another route.
    # Which is also why pagy's `max_limit` stays unset: the query string is still not
    # asked, and this is the one thing that is.
    def recourse_limit
      limit = cookies[Recourse::LIMIT_STORAGE].to_i

      Recourse::LIMITS.include?(limit) ? limit : Recourse::LIMITS.first
    end
  end
end
