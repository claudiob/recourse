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

  # Whether a model's rows can be drawn on a map: by the place each keeps, by its point,
  # or by the point of the record it names as `recourse_mapped`.
  def self.mappable?(model) = placed?(model) || pointed?(model) || pointed?(mapped(model))

  # Whether a model keeps both halves of a point among its own columns.
  def self.pointed?(model) = model.present? && (POINT_COLUMNS - model.column_names).empty?

  # The model a row's point is kept on, where it is kept on another one.
  def self.mapped(model)
    name = model.recourse_mapped
    name && model.reflect_on_association(name).klass
  end

  # The rows with the point of the record each names as `recourse_mapped` read alongside
  # their own columns, which is where a map reads a point from. Any row with none is
  # still read, and is nowhere on the map.
  def self.with_points(relation)
    target = mapped(relation.klass) or return relation
    own = relation.klass.arel_table[Arel.star]
    relation = relation.select(own) if relation.select_values.empty?
    relation.left_joins(relation.klass.recourse_mapped)
            .select(*POINT_COLUMNS.map { |column| target.arel_table[column] })
  end

  # The layer a model's places are drawn on, or nil for a model that is no geography.
  def self.boundary(model) = BOUNDARIES[model.model_name.element.to_sym]

  # Whether a model's rows keep a place ID, which an area or a pin at a place is drawn from.
  def self.placed?(model) = model.column_names.include? PLACE_COLUMN

  # The key the Maps API is called with and the map the rows are drawn on, read from the
  # host's own credentials under `google_maps` as `api_key` and `map_id`.
  def self.google_maps
    Rails.application.credentials[:google_maps] || {}
  end
end
