# A place signed off, at most one to a place. Nothing to fill in, so it is made by the
# act rather than by a form: the singular resource whose page is either the record or
# the button that makes one.
class Seal < ApplicationRecord
  belongs_to :place

  # What the unique index says, said where a write can be turned down rather than
  # raised at: the button is hidden once there is one, and a post that arrives anyway
  # -- a second tab, a double click -- is refused rather than answered with a 500.
  validates :place_id, uniqueness: true
end
