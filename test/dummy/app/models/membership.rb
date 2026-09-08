# A person on a team, which is the join a page edits a row at a time rather than a
# record anybody reads.
class Membership < ApplicationRecord
  belongs_to :person
  belongs_to :team
end
