# Reopened for the map a table of places can be read as.
module Recourse
  # The column a row is drawn on a Google map by: the ID Google gives a place.
  PLACE_COLUMN = 'google_place_id'

  # The two a row is pinned by where it keeps no place: a point needs no lookup.
  POINT_COLUMNS = %w[latitude longitude].freeze

  # The boundary layer a model's places are areas on, by the name the model goes by —
  # the four geographies a host is likely to keep, in Google's words for each. A model
  # named otherwise has its places pinned.
  BOUNDARIES = {
    state: :administrative_area_level_1, county: :administrative_area_level_2,
    city: :locality, zip: :postal_code,
  }.freeze

  # Whether a model's rows can be drawn on a map: by the place each keeps, or its point.
  def self.mappable?(model) = placed?(model) || (POINT_COLUMNS - model.column_names).empty?

  # The layer a model's places are drawn on, or nil for a model that is no geography.
  def self.boundary(model) = BOUNDARIES[model.model_name.singular.to_sym]

  # Whether a model's rows keep a place ID, which an area or a pin at a place is drawn from.
  def self.placed?(model) = model.column_names.include? PLACE_COLUMN

  # The key the Maps API is called with and the map the rows are drawn on, read from the
  # host's own credentials under `google_maps` as `api_key` and `map_id`.
  def self.google_maps
    Rails.application.credentials[:google_maps] || {}
  end
end
