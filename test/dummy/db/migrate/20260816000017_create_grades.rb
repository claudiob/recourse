class CreateGrades < ActiveRecord::Migration[8.1]
  # What an inspection can come back as. Four rows written here and read forever
  # after, which is the shape reference data takes — and an app is entitled to keep no
  # timestamps on a table like that.
  GRADES = %w[Excellent Good Fair Poor].freeze

  # No `t.timestamps`, on purpose and as the one table in this app without them. A
  # menu is the only place it matters: `cache` keys a relation on `MAX(updated_at)`
  # without asking whether the table has one, so a form offering these would answer
  # 500 rather than a list of four words.
  def change
    create_table :grades do |t|
      t.string :name, null: false
    end

    add_index :grades, :name, unique: true
    # Optional: an audit is written before anybody has said how it went.
    add_reference :audits, :grade, foreign_key: true

    up_only { connection.execute grade_rows }
  end

private

  def grade_rows
    values = GRADES.map { |name| "('#{name}')" }.join ', '

    "insert into grades (name) values #{values}"
  end
end
