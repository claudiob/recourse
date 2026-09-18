# A place signed off, at most one to a place. Nothing to fill in, so it is made by the
# act rather than by a form: the bare action whose model refuses a second one.
class Seal < ApplicationRecord
  belongs_to :place

  # What the unique index says, said where a write can be turned down rather than
  # raised at: a post that arrives for a place already sealed -- a second tab, a
  # double click -- is refused rather than answered with a 500.
  validates :place_id, uniqueness: true

  # A seal keeps no name of its own -- it is the place it signs off, and the date it
  # was signed. Which is what leaves it the model whose pages are named by this rather
  # than by a column.
  def to_s = "#{place.name}, sealed"
end
