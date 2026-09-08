# Reopened for whose clock the gem's own pages are read against.
module Recourse
  # Where the reader's own time zone is kept in their browser, for the server to read
  # back. An IANA name — `America/Los_Angeles` — as the browser itself reports it.
  ZONE_STORAGE = 'recourse-zone'
end
