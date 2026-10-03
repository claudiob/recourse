class CreateBadges < ActiveRecord::Migration[8.1]
  # The table of the one model this app keeps in a module of its own, Admin::Badge: a
  # route in that module lists it, rather than a top-level class of the same name.
  def change
    create_table :badges do |t|
      t.references :person, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
