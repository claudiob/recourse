class Step
  # What a step says for itself: which rows its position is counted among, and the
  # second order no table draws.
  module Recoursive
    extend ActiveSupport::Concern

    # A step points two ways and its place is among its team's, which the gem asks
    # rather than guesses: numbering a step among every step there is would be the
    # wrong answer given quietly, and at the first write.
    def recourse_siblings = team.steps

    class_methods do
      # `ranking` is a step's place among one person's, which the listing under a
      # person is dragged into order by and no other page has any use for: a bare
      # number beside the grips is the row's own place written out again.
      def recourse_hidden = :ranking
    end
  end
end
