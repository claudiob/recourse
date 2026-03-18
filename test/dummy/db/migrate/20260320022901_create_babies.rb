class CreateBabies < ActiveRecord::Migration[8.1]
  def change
    create_table :babies do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
