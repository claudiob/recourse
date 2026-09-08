# A line kept about something, in an order somebody put them in. Points one way and no
# other, so the rows its position is counted among are worked out rather than named.
class Note < ApplicationRecord
  include Recoursive

  belongs_to :about, polymorphic: true

  validates :body, presence: true
end
