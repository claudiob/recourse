# A crew a place belongs to. Few enough of them that a form lists every one, which
# is the other half of what ZIP proves.
class Team < ApplicationRecord
  include Recoursive

  has_many :places, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships

  validates :name, presence: true, uniqueness: true
end
