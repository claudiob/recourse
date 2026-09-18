module Admin
  module People
    module Steps
      # Where a drop on that listing lands. The gem draws a positions controller under
      # every index it knows about, and this one has to be told the same thing the
      # index was — which column — or a drag would write a step's place among its
      # team's steps from a page showing a person's.
      class PositionsController < Recourse::PositionsController
        include Ranking
      end
    end
  end
end
