# A line kept about something. Points one way and no other.
class Note < ApplicationRecord
  belongs_to :about, polymorphic: true

  validates :body, presence: true
end
