# A note kept about somebody, which outlives them: deleting a person leaves their
# memos standing, without a person.
class Memo < ApplicationRecord
  include Recoursive, Searchable

  belongs_to :person, optional: true
  # A key naming no one table, which the gem has to notice before it reaches for
  # a class that is not there.
  belongs_to :about, polymorphic: true, optional: true

  # Two keys, so which one a position is counted within is this model's to say and not
  # the gem's to guess: a memo is ordered among the ones about the same person, and
  # what it happens to be about has no bearing on where it sits.
  def recourse_siblings = Memo.where(person_id:)
end
