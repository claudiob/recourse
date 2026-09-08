class CreateSeals < ActiveRecord::Migration[8.1]
  def change
    create_table :seals do |t|
      # Unique, which is what makes it one seal rather than a list of them.
      t.references :place, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end

    # Every third place, so both of the pages a singular resource has -- the record
    # read out, and the button that makes one -- are reachable.
    up_only do
      Place.order(:id).each_with_index do |place, index|
        place.create_seal! if (index % 3).zero?
      end
    end
  end
end
