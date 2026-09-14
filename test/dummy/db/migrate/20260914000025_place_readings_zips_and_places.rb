# Where each ZIP lies and each reading was taken, as the ID Google gives the place, and
# where each place stands, as its coordinates — which is what lets a page of any of them be
# read as a map rather than a table: the ZIPs filled in as postal areas, the readings
# pinned at them, the places pinned where they stand.
class PlaceReadingsZipsAndPlaces < ActiveRecord::Migration[8.1]
  # Google's own IDs for the postal codes, geocoded once from the codes and kept in
  # `db/zip_places.txt` the way the counties' rows are: the map draws nothing for an ID
  # Google does not know, and six of the codes it has never heard of, so those ZIPs keep
  # none and stay off the map — as a row with nowhere to be drawn should.
  PLACES = Rails.root.join('db/zip_places.txt').readlines(chomp: true).to_h(&:split)

  def change
    add_column :readings, :google_place_id, :string
    add_column :zips, :google_place_id, :string
    add_column :places, :latitude, :decimal, precision: 8, scale: 5
    add_column :places, :longitude, :decimal, precision: 8, scale: 5

    up_only do
      PLACES.each do |code, place|
        connection.execute "update zips set google_place_id = '#{place}' where code = '#{code}'"
      end
      # A reading was taken in the ZIP that shares its number: a pin at a real place.
      connection.execute <<~SQL.squish
        update readings set google_place_id =
          (select google_place_id from zips where zips.id = readings.id)
      SQL
      connection.execute <<~SQL.squish
        update places set latitude = 37 + id / 100.0, longitude = -122 - id / 100.0
      SQL
    end
  end
end
