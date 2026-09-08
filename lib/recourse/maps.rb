# Reopened for the map a table of places can be read as.
module Recourse
  # The column a row is placed on a Google map by: the ID Google gives a place.
  PLACE_COLUMN = 'google_place_id'

  # Whether a model's rows can be drawn on a map, which is whether they keep a place ID.
  def self.mappable?(model) = model.column_names.include? PLACE_COLUMN

  # The key the Maps API is called with and the map the places are drawn on, read from
  # the host's own credentials under `google_maps` — the shape the host already keeps
  # them in for a map of its own.
  def self.google_maps
    Rails.application.credentials[:google_maps] || {}
  end
end
