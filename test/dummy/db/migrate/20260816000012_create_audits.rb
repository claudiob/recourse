class CreateAudits < ActiveRecord::Migration[8.1]
  def change
    create_table :audits do |t|
      # Unique, which is what makes it one audit rather than a list of them.
      t.references :place, null: false, foreign_key: true, index: { unique: true }
      t.string :finding, null: false

      t.timestamps
    end

    # Every other place, so both halves of a singular page are reachable: the record
    # read out where there is one, and what the page says where there is not.
    up_only do
      Place.order(:id).each_with_index do |place, index|
        place.create_audit! finding: "Audited #{place.name} and found nothing amiss." if index.even?
      end
    end
  end
end
