# A week memos were written in, and how many. A resource with no rows of its own: the
# weeks are counted out of the memos rather than read off a table, so there is nothing
# to search by, to sort by or to point a key at — which is what `Aggregate` answers.
class Week
  include ActiveModel::Model, Recourse::Aggregate

  attr_reader :starting_on, :memos

  def initialize(starting_on, memos)
    @starting_on = starting_on
    @memos = memos
  end

  # The weeks the memos of this app fall into, newest first, one row a week.
  def self.all
    Memo.all.group_by { |memo| memo.created_at.to_date.beginning_of_week }
        .sort_by { |starting_on, _| -starting_on.to_time.to_i }
        .map { |starting_on, memos| new starting_on, memos.size }
  end

  def to_s = "Week of #{starting_on}"
end
