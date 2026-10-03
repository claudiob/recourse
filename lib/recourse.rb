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
require_relative 'recourse/public_caches'
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
  @retrievable = []
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
  def self.model?(name) = namespaced_model(name) || model_name(name).safe_constantize

  # A namespaced resource is `admin/sources`, and the model it lists is a Source.
  def self.model_name(name) = name.to_s.split('/').last.classify

  # Whether a model answers the name, asked of the constants rather than the classes:
  # the routes ask while they draw, and loading a model then is what Rails 8.2 warns
  # about.
  def self.model_defined?(name)
    namespaced_names(name).any? { |namespaced| constant namespaced, load: false } ||
      Object.const_defined?(model_name(name))
  end

  # A model the app keeps in the route's own module, where there is one: `admin/users`
  # lists an Admin::User, and so does `admin/posts/users`, nested under a post.
  # Only an Active Record model counts, so a concern or a host's own class that shares
  # the name never takes a page over; and where there is none, `admin/comments` lists a
  # Comment as it always has.
  private_class_method def self.namespaced_model(name)
    namespaced_names(name).each do |namespaced|
      model = constant namespaced
      return model if model.is_a?(Class) && model < ActiveRecord::Base
    end

    nil
  end

  # The names a model in the route's modules goes by, innermost module first. The
  # segment a nested route adds for its parent is a module no model lives in, so the
  # module around it is asked next.
  private_class_method def self.namespaced_names(name)
    *modules, last = name.to_s.split '/'
    modules.size.downto(1).map { |depth| [*modules[0, depth], last].join('/').classify }
  end

  # The constant a name gives, looked up one module at a time and never through Object:
  # `safe_constantize` answers `Admin::Comment` with the top-level Comment, since a module
  # looks its constants up there too. `load: false` stops short of the last one,
  # answering only whether it is there.
  private_class_method def self.constant(name, load: true)
    *modules, last = name.split '::'
    scope = modules.inject Object do |outer, part|
      break unless outer.const_defined? part, false

      outer.const_get part, false
    end
    return unless scope.is_a? Module
    return unless scope.const_defined? last, false

    load ? scope.const_get(last, false) : true
  end

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
