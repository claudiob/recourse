class CreateNotes < ActiveRecord::Migration[8.1]
  # How many of them each of the first three ZIPs keeps. All different on purpose: a
  # page scoped to its own parent and one listing every row read the same where the
  # counts match, and a third parent is what keeps two of them short of the whole.
  PER_ZIP = { 1 => 3, 2 => 2, 3 => 1 }.freeze

  # A note is about one thing and points nowhere else, which is what makes it the case
  # a memo cannot be: `Recourse::Arranged` reads the parent its position counts within
  # off the one key there is, and a memo has two.
  def change
    create_table :notes do |t|
      # Polymorphic, and this one filled: a route names the far side of it, so the gem
      # has a parent to find where the key itself names no table.
      t.references :about, polymorphic: true, null: false
      t.string :body, null: false
      # No default, so nothing but the model can answer for it — which is the whole
      # point of the concern that does.
      t.integer :position, null: false

      t.timestamps
    end

    add_index :notes, %i[about_type about_id position]

    up_only { connection.execute note_rows }
  end

private

  def note_rows
    values = PER_ZIP.flat_map do |zip, count|
      (1..count).map do |number|
        "('ZIP', (select id from zips order by id limit 1 offset #{zip - 1}), " \
          "'Note #{number} about ZIP #{zip}.', #{number}, current_timestamp, current_timestamp)"
      end
    end

    <<~SQL.squish
      insert into notes (about_type, about_id, body, position, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
