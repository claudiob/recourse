# Where each reading was taken, as the ID Google gives the place — which is what lets
# a page of them be read as a map rather than a table.
class PlaceReadings < ActiveRecord::Migration[8.1]
  def change
    add_column :readings, :google_place_id, :string

    up_only { connection.execute "update readings set google_place_id = 'ChIJ' || id" }
  end
end
