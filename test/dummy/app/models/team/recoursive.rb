class Team
  # Extends Team with the order its rows are read in, which here is one a reader set
  # rather than one the database found.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # `:positionable` where `:asc` would go: the rows come back by `position`, and
      # the table that draws them offers no heading to sort by and no box to search
      # with, because a second way to read them would contradict the order somebody
      # put them in.
      def recourse_order = { position: :positionable }
    end
  end
end
