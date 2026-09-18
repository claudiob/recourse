class ArrangeTeams < ActiveRecord::Migration[8.1]
  # The column is the whole of the opt-in, so this migration is the whole of what
  # makes the teams table one a reader drags into order: no declaration follows it.
  # A flat table, teams pointing nowhere, which is the shape whose rows are positioned
  # among the whole table rather than within a parent.
  def change
    add_column :teams, :position, :integer

    # In the order they were made, which is the order they were read in before this.
    up_only { connection.execute 'update teams set position = id' }

    change_column_null :teams, :position, false
    add_index :teams, :position
  end
end
