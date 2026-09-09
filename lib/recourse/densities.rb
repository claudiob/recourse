# Reopened for the one thing a reader says about how much a phone spells out.
module Recourse
  # Where a reader's say on a phone's chrome is kept: a cookie, since the server reads it
  # back and draws the words in or leaves them out, rather than drawing and then hiding.
  # `expanded` puts the words beside every icon; anything else, or nothing, is compact.
  DENSITY_STORAGE = 'recourse-density'
end
