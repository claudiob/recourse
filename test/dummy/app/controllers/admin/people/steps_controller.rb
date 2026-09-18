module Admin
  module People
    # A listing arranged by a column the model does not keep. That is the whole of the
    # override: the rows are the ones the key already narrows to, and the order comes
    # from the column named below rather than from a scope written here.
    class StepsController < RecoursesController
      include Ranking
    end
  end
end
