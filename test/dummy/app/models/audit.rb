# What an inspection found at a place, at most one to a place. The singular resource
# the gem finds for itself: nothing but the place names it, so there is no id to look
# up and no controller of this app's own to look one up with.
class Audit < ApplicationRecord
  belongs_to :place
  # Optional, and the reason this form draws a menu: grades keep no timestamps.
  belongs_to :grade, optional: true

  validates :finding, presence: true
end
