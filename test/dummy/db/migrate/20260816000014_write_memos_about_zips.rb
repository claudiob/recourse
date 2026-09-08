class WriteMemosAboutZips < ActiveRecord::Migration[8.1]
  # How many of the memos each of the first two ZIPs is about. Different on purpose:
  # a page scoped to its own parent and one listing every row read the same where the
  # two counts match.
  ABOUT = { 1 => 3, 2 => 2 }.freeze

  # `about` was made in CreateMemos and left empty, which proved the gem asks what a
  # key points at before reaching for a class. Now that a route can name the far side
  # of one, some rows have to be about something.
  def change
    up_only { ABOUT.each { |zip, count| connection.execute memos_about(zip, count) } }
  end

private

  # Ordered and offset, so the two ZIPs take different memos and the rest stay empty:
  # a memo about nothing is still what `optional: true` is there for.
  def memos_about(zip, count)
    taken = ABOUT.keys.take_while { |one| one < zip }.sum { |one| ABOUT[one] }

    <<~SQL.squish
      update memos set about_type = 'ZIP', about_id = (
        select id from zips order by id limit 1 offset #{zip - 1}
      ) where id in (select id from memos order by id limit #{count} offset #{taken})
    SQL
  end
end
