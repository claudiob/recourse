require 'pagy'
# Before searchable.rb, so its `extend` lands ahead of Ransack's own defaults.
require 'ransack'
require 'unicon'

require_relative 'recourse/version'
require_relative 'recourse/bookmarks'
require_relative 'recourse/colors'
require_relative 'recourse/columns'
require_relative 'recourse/themes'
require_relative 'recourse/icons'
require_relative 'recourse/controllers'
require_relative 'recourse/densities'
require_relative 'recourse/helpers'
require_relative 'recourse/limits'
require_relative 'recourse/orders'
require_relative 'recourse/writes'
require_relative 'recourse/zones'
require_relative 'recourse/broadcasting'
require_relative 'recourse/recoursive'
require_relative 'recourse/registry'
require_relative 'recourse/routing'
require_relative 'recourse/scopes'
require_relative 'recourse/search'
require_relative 'recourse/titles'
require_relative 'recourse/searchable'
require_relative 'recourse/engine'

# Namespace for the gem: the routes.rb DSL and the screens it mounts.
module Recourse
  # What Rails keeps rather than what a record is about, in the order a page shows
  # them. Named once: three places ask which columns these are.
  TIMESTAMPS = %w[created_at updated_at].freeze

  class << self
    # Resources `recourses` has drawn, in the order config/routes.rb lists them.
    attr_reader :declared
  end

  @declared = []
  @nested = {}
  @parents = {}
  @declared_bookmarks = nil

  # Columns a user may set: the form offers these, the show page reads these out, and
  # `create` permits these. A counter cache is none of a user's business — Rails keeps
  # it, so a form that offered one would let it be typed over.
  def self.editable_columns(model)
    ordered model, model.column_names - ['id', *TIMESTAMPS] - model.recourse_counters.keys -
                   hidden_columns(model)
  end

  # Columns no screen shows: whatever the model asked to hide through
  # `recourse_hidden` — one name or a list, taken either way — and the column Rails
  # reserves for single table inheritance. A class name is machinery, not something
  # to read out or type over.
  def self.hidden_columns(model)
    Array(model.recourse_hidden).map(&:to_s) + [model.inheritance_column]
  end

  # The names a column is validated under: its own, and — where it is a foreign key
  # — the association's, since `belongs_to` validates the record it points at rather
  # than the number pointing there. Two questions where a column is a key, one
  # everywhere else.
  def self.validated_names(column)
    [column, column.delete_suffix('_id')].uniq
  end

  # The model a resource is named after. A controller the gem defined has nothing
  # else to go on, so a name that resolves to no model is a routes file to fix
  # rather than a `NameError` from somewhere inside a view.
  def self.model(name)
    model?(name) || raise(Error, I18n.t('recourse.missing_model', name:, model: model_name(name)))
  end

  # The same, answering nil where there is no such model rather than raising. A bare
  # action is a verb — `recourses :sweeps, only: :create` — and the gem labels its button
  # from the path alone, so whether a name has a model behind it has to be a question
  # and not an accusation.
  def self.model?(name) = model_name(name).safe_constantize

  # A namespaced resource is `admin/sources`, and the model it lists is a Source.
  def self.model_name(name) = name.to_s.split('/').last.classify

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
