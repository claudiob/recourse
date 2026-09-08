class TagPlaces < ActiveRecord::Migration[8.1]
  # What a few of the places are tagged with. Three of them, one of them and none of
  # them, so a list reads as its plural, as its singular and as the dash between them.
  TAGS = {
    1 => ['Riverside', 'Terrace', 'Wheelchair access'],
    2 => ['Parking'],
  }.freeze

  def change
    # A list, which SQLite has no column type for: `array: true` is a PostgreSQL
    # option and every other adapter raises on it. What makes this one a list is the
    # model's `serialize`, which reports the same wrapped type a `text[]` does — so
    # the gem cannot tell this from the real thing, which is the point of it being
    # here. The column is indexed because the search box has to see a list and pass
    # over it, and only an indexed column ever reaches that question.
    add_column :places, :tags, :text
    add_index :places, :tags

    up_only do
      # The model may have loaded its columns for an earlier migration in this same
      # run, which would leave it not knowing about the one just added — and writing
      # through an attribute it has never heard of casts nothing and raises.
      Place.reset_column_information

      TAGS.each do |position, tags|
        place = Place.order(:id).offset(position - 1).first
        place&.update_column :tags, tags
      end
    end
  end
end
