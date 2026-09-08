class ArrangeTeamsAndMemos < ActiveRecord::Migration[8.1]
  # Two tables somebody puts in order by hand, and they are arranged at different
  # levels on purpose.
  #
  # Teams are the plainest case: nothing nests them, so the whole table is the one
  # scope and their own index is where a position means something. `uid` beside the
  # column, indexed by nothing, is what proves the check refuses a column no table
  # can be read in the order of.
  #
  # Memos are the other case: six of them a person, so a position counts within one
  # person and `/people/1/memos` is the level. Read across every person at `/memos`
  # the same numbers run 1..6 ten times over, which is an order of nothing — so that
  # page is left to sort and search like any other.
  def change
    add_column :teams, :position, :integer, null: false, default: 0
    add_index :teams, :position

    add_column :memos, :position, :integer, null: false, default: 0
    add_index :memos, %i[person_id position]

    up_only do
      connection.execute 'update teams set position = id'
      connection.execute memo_positions
    end
  end

private

  # One to six within each person, in the order the rows were written.
  def memo_positions
    <<~SQL.squish
      update memos set position = (select count(*) from memos others
        where others.person_id = memos.person_id and others.id <= memos.id)
    SQL
  end
end
