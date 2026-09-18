# One move a team works through. The table positioned within a parent — a step holds a
# place among its team's steps, and a reader sets it by dragging a row — and the one
# pointing two ways, which is what leaves `recourse_siblings` a question only the
# model can answer.
class Step < ApplicationRecord
  include Ranked, Recoursive

  belongs_to :team
  # Whoever is to do it. A step is read under a person too, in the order they mean to
  # work through theirs, which is a second place and a second column.
  belongs_to :person

  validates :name, presence: true
end
