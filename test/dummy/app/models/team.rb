# A crew a place belongs to. Few enough of them that a form lists every one, which
# is the other half of what ZIP proves.
class Team < ApplicationRecord
  has_many :places, dependent: :destroy
  # Reached through them, and counted by them: a `has_many through:` keeps no counter of
  # its own, and `places_count` is the number of rows the tab over this one is about.
  has_many :zips, through: :places
  # The rows a step's position is counted among, which is what a team's own listing
  # of them is dragged into order by.
  has_many :steps, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # The crew a place falls back to, which is kept the way an app keeps any row its other
  # rows lean on: the page is told, rather than the row taken.
  before_destroy { throw :abort if name == 'Night Shift' }
end
