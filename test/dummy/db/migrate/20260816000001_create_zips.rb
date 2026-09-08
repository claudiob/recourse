class CreateZips < ActiveRecord::Migration[8.1]
  def change
    create_table :zips do |t|
      # Five characters exactly, which the model states as a length — and a length is
      # what tells a form to ask for a code rather than list every row.
      t.string :code, limit: 5, null: false
      # Written once by this migration and never again: what `readonly_attributes`
      # keeps off a form and off the table it would otherwise head.
      t.string :fips, limit: 5, null: false
      t.string :city, null: false
      t.integer :places_count, null: false, default: 0

      t.timestamps
    end

    add_index :zips, :code, unique: true
    add_index :zips, :fips, unique: true
    # Not unique: two towns share a name often enough that the index is about
    # sorting and searching rather than about identity.
    add_index :zips, :city

    # One row over MENU_LIMIT, which is the whole point of this table: a foreign key
    # pointing here is typed rather than picked from a menu of every row.
    up_only { connection.execute zip_rows }
  end

private

  def zip_rows
    values = (1..101).map do |number|
      code = format '%05d', 90_000 + number
      fips = format '%05d', number * 7
      "('#{code}', '#{fips}', 'Town #{format '%03d', number}', 0, #{now}, #{now})"
    end

    <<~SQL.squish
      insert into zips (code, fips, city, places_count, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end

  def now = 'current_timestamp'
end
