class AddDetailsToPlaces < ActiveRecord::Migration[8.1]
  # What a service answered about the place, kept whole. Long and nested on purpose:
  # a payload is the one value a table cannot draw — as wide as the page on its own,
  # and a column of them a table nobody can read — so this is what proves the index
  # leaves it out while the record's own page still reads it.
  #
  # Added after `t.timestamps` rather than beside the other columns, which is what a
  # later migration always does, so the table's own rule that the timestamps come last
  # is exercised by a column that arrived after them.
  DETAILS = {
    'source' => 'https://example.com/places?include=amenities,hours,ratings&format=json',
    'amenities' => %w[parking wifi step_free_access hearing_loop cycle_racks],
    'hours' => { 'mon' => '09:00-17:00', 'sat' => '10:00-16:00', 'sun' => nil },
    'ratings' => { 'cleanliness' => 4.6, 'staff' => 4.8, 'value' => 4.1 },
  }

  def change
    add_column :places, :details, :json

    # The hash itself, not its JSON: `update_all` casts through the attribute's own
    # type, so handing it a string would encode an already-encoded value and read back
    # as one. No validation and no callback either, over rows a migration has no
    # business putting through them twice.
    up_only do
      Place.reset_column_information
      Place.update_all details: DETAILS
    end
  end
end
