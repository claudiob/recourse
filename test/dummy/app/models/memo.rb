# A note kept about somebody, which outlives them: deleting a person leaves their
# memos standing, without a person.
class Memo < ApplicationRecord
  include Recoursive, Searchable

  belongs_to :person, optional: true
  # A key naming no one table, which the gem has to notice before it reaches for
  # a class that is not there.
  belongs_to :about, polymorphic: true, optional: true
end
