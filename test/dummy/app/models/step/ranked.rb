class Step
  # Fills `ranking` and closes its gaps: a step's place among the steps of whoever is
  # to do them, which the listing under a person is dragged into order by.
  #
  # The gem maintains `position` and only `position` — a model keeps one arranged
  # column, and a second listing of it is a second column that only its own controller
  # knows about — so this half is the host's. It is what a host writes for such a
  # listing, and `Recourse::Positioning` is public for exactly this.
  #
  # Nothing here shifts what a move displaced. `Positioning#move` shifts the block and
  # then writes the row, so a second shift would leave two steps holding one number.
  module Ranked
    extend ActiveSupport::Concern

    included do
      before_validation :rank_last, on: :create
      after_destroy :close_ranking
    end

  private

    # The rows a ranking is counted among, which is `recourse_siblings` said for the
    # other key.
    def ranked = person.steps

    def rank_last
      self.ranking ||= ranked.maximum(:ranking).to_i + 1
    end

    def close_ranking
      Recourse::Positioning.new(ranked, 'ranking').close ranking
    end
  end
end
