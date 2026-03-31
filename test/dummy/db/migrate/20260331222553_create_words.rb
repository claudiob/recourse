class CreateWords < ActiveRecord::Migration[8.1]
  def change
    create_table :words do |t|
      t.references :baby, null: false, foreign_key: true
      t.string :content

      t.timestamps
    end
  end
end
