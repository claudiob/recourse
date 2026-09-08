# What took a reading. Its name is bounded, so a form asks for one to be typed rather
# than listing them — and two sensors share a name, which is what makes this the table
# a typed key cannot always answer for: the words name a sensor, not which one.
class Sensor < ApplicationRecord
  has_many :readings, dependent: :nullify

  validates :name, presence: true, length: { maximum: 30 }
end
