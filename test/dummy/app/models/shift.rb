# A stretch of somebody's time, which is the one thing a week is drawn of: the two
# ends of it are what earn this table a calendar beside its table.
class Shift < ApplicationRecord
  belongs_to :person

  validates :name, presence: true
  # The database says so too, and the grid is drawn between the two: a row missing
  # either end is a row with nowhere to stand.
  validates :starts_at, presence: true
  validates :ends_at, presence: true
end
