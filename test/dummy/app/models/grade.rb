# What an inspection came back as. The table this app keeps no timestamps on, so it is
# what proves a menu can be offered over one: nothing versions such a relation, and a
# cache key built from `MAX(updated_at)` would ask a column that is not there.
#
# No length on the name, so a form lists the four of them rather than asking for one to
# be typed — which is what puts these behind a combobox at all.
class Grade < ApplicationRecord
  has_many :audits, dependent: :nullify

  validates :name, presence: true
end
