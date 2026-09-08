class CreateReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :readings do |t|
      # A measurement, and nothing that names the row it is on: two readings share a
      # depth often enough that only the id tells one from another.
      t.integer :depth, null: false
      # A reading taken where the last one was, so this is the key whose menu would be
      # the whole of this table.
      t.references :previous_reading, foreign_key: { to_table: :readings }

      t.timestamps
    end

    # One row over MENU_LIMIT, as the ZIPs are: past that a menu of every row is a page
    # of HTML nobody reads. What this table adds beside them is a label that is not a
    # word, so the search box cannot be what offers the key instead.
    up_only { connection.execute reading_rows }
  end

private

  def reading_rows
    values = (1..101).map { |number| "(#{number * 3}, #{now}, #{now})" }

    <<~SQL.squish
      insert into readings (depth, created_at, updated_at) values #{values.join ', '}
    SQL
  end

  def now = 'current_timestamp'
end
