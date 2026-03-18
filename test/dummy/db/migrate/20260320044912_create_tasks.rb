class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.boolean :running

      t.timestamps
    end
  end
end
