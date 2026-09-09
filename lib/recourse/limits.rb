# Reopened for how much of a table a page shows at once.
module Recourse
  # Rows to a page, in the order the menu offers them: a screenful for a reader reading
  # a table, and the one step up for a reader scanning it. Named once — the controller
  # checks a cookie against this list, and the menu is drawn from it.
  LIMITS = [15, 100].freeze

  # Where a reader's chosen page size is kept in their browser. A cookie rather than
  # local storage, which the scheme is kept in: pagy runs on the server, and a cookie
  # is the only storage the server is sent.
  LIMIT_STORAGE = 'recourse-limit'
end
