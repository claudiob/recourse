class AddBabyToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :baby, null: true, foreign_key: true
  end
end
