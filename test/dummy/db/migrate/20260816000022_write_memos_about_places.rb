class WriteMemosAboutPlaces < ActiveRecord::Migration[8.1]
  # Every place but the first, which the suite keeps for itself: `TestRecoursesActions`
  # deletes whatever a place's memo action is pointed at and does not put it back, so a
  # row seeded about that one would drain away on the first run.
  KEPT = 1

  # A place's `Delete memo` button removes what is about it, and until now nothing was:
  # `about` named a ZIP on five rows and nothing at all on the rest, so the button was
  # one that deleted nothing wherever it was clicked.
  def change
    up_only { (KEPT...Place.count).each { |place| connection.execute memo_about(place) } }
  end

private

  # The next memo that is about nothing yet, so this takes rows the ZIP backfill left
  # and never points one memo at two things. Plenty are left over either way: a memo
  # about nothing is still what `optional: true` is there for.
  def memo_about(place)
    <<~SQL.squish
      update memos set about_type = 'Place', about_id = (
        select id from places order by id limit 1 offset #{place}
      ) where id = (select id from memos where about_id is null order by id limit 1)
    SQL
  end
end
