# A note kept about somebody, which outlives them: deleting a person leaves their
# memos standing, without a person.
class Memo < ApplicationRecord
  include Recoursive

  belongs_to :person, optional: true
end
