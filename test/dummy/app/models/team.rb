# A crew a place belongs to. Few enough of them that a form lists every one, which
# is the other half of what ZIP proves.
class Team < ApplicationRecord
  has_many :places, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
