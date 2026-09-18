class ArrangeGrades < ActiveRecord::Migration[8.1]
  # The table with no timestamps, arranged. No page lists grades, which is the point:
  # the column is the opt-in and the callbacks follow the column rather than the
  # routes, so a grade made in a console is numbered like one made behind a form —
  # and one that goes closes the gap behind it with no `updated_at` to touch.
  def change
    add_column :grades, :position, :integer

    up_only { connection.execute 'update grades set position = id' }

    change_column_null :grades, :position, false
    add_index :grades, :position
  end
end
