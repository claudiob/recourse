require 'bh'
require 'pagy'
# Before searchable.rb, so its `extend` lands ahead of Ransack's own defaults.
require 'ransack'
require 'unicon'

require_relative 'recourse/version'
require_relative 'recourse/assets'
require_relative 'recourse/attachments'
require_relative 'recourse/blobs'
require_relative 'recourse/bookmarks'
require_relative 'recourse/calendars'
require_relative 'recourse/colors'
require_relative 'recourse/bands'
require_relative 'recourse/columns'
require_relative 'recourse/counters'
require_relative 'recourse/searches'
require_relative 'recourse/themes'
require_relative 'recourse/icons'
require_relative 'recourse/controllers'
require_relative 'recourse/densities'
require_relative 'recourse/helpers'
require_relative 'recourse/limits'
require_relative 'recourse/maps'
require_relative 'recourse/orders'
require_relative 'recourse/positions'
require_relative 'recourse/positioning'
require_relative 'recourse/writes'
require_relative 'recourse/zones'
require_relative 'recourse/positionable'
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

  # The shapes a page of rows takes besides the table, by the format each is asked for.
  # Both are the same HTML drawn another way: no template of their own, and one action.
  SHAPES = %i[map cal].freeze

  class << self
    # Resources `recourses` has drawn, in the order config/routes.rb lists them.
    attr_reader :declared
  end

  @declared = []
  @nested = {}
  @parents = {}
  @declared_bookmarks = nil

  # The model a resource is named after. A controller the gem defined has nothing else
  # to go on, so a name resolving to no model is a routes file to fix rather than a
  # `NameError` from somewhere inside a view.
  def self.model(name)
    model?(name) || raise(Error, I18n.t('recourse.missing_model', name:, model: model_name(name)))
  end

  # The same, answering nil where there is no such model rather than raising. A bare
  # action is a verb — `recourse :sweep, only: :create` — and the gem labels its button
  # from the path alone, so whether a name has a model behind it has to be a question
  # and not an accusation.
  def self.model?(name) = model_name(name).safe_constantize

  # A namespaced resource is `admin/sources`, and the model it lists is a Source.
  def self.model_name(name) = name.to_s.split('/').last.classify

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
