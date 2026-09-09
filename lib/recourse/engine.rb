# rails/engine alone raises NoMethodError: railtie.rb calls delegate_missing_to too early.
require 'rails'
# Turbo's engine isolates its namespace as it loads, which wants Action Dispatch first;
# required here since Bundler loads what a host's Gemfile names, not its dependencies.
require 'action_dispatch'
require 'turbo-rails'

require_relative 'routes'

module Recourse
  # Hooks the gem into a host app's boot so its controllers and views are found.
  class Engine < ::Rails::Engine
    # Prefix the gem answers for with a file. `Rack::Static` matches on
    # `start_with?`, so dropping the slash would swallow `/recourses` itself.
    STATIC_URLS = %w[/recourse/].freeze

    # Every file is asked for again on every full load, and answered `304 Not Modified`
    # while it stands. The URL of a file never changes between versions of the gem, so
    # a browser told to keep one for hours ran the previous version's script — with the
    # tooltip a release had just taken away — until the hours were up.
    STATIC_HEADERS = [[:all, { 'cache-control' => 'no-cache' }]].freeze

    # Initializers all run before routes are drawn, so `recourses` exists in time.
    initializer 'recourse.routes' do
      ActionDispatch::Routing::Mapper.include Scopes, Routes
    end

    # Serves what a page needs, since a host may run no asset pipeline at all. The
    # prefix keeps its slash: without it `/recourses` would be served as a file.
    # Turbo answers first, by exact path — matched on the prefix alone, the statics
    # below would swallow it with a 404 instead of passing it on. Then vendored
    # files, then our own JavaScript, each cascading so the next shares the URL, and
    # finally our own stylesheets — the palettes. All of it sits before
    # `Rails::Rack::Logger`, so fetching a stylesheet writes no `Started GET` line:
    # a file is not what a log is about, and placement says so without the gem
    # touching a host's logging.
    initializer 'recourse.assets' do |app|
      # turbo-rails' own bundle: the same Turbo plus the cable element, in the
      # version that gem signs its streams for. A dependency rather than something
      # to find, since a page here cannot do without it.
      app.middleware.insert_before Rails::Rack::Logger, Rack::Static,
                                   urls: { '/recourse/turbo.min.js' => 'turbo.min.js' },
                                   root: Turbo::Engine.root.join('app/assets/javascripts').to_s,
                                   header_rules: STATIC_HEADERS
      app.middleware.insert_before Rails::Rack::Logger, Rack::Static,
                                   urls: STATIC_URLS, root: Engine.root.join('vendor'),
                                   header_rules: STATIC_HEADERS, cascade: true
      app.middleware.insert_before Rails::Rack::Logger, Rack::Static,
                                   urls: STATIC_URLS, root: Engine.root.join('app/javascript'),
                                   header_rules: STATIC_HEADERS, cascade: true
      app.middleware.insert_before Rails::Rack::Logger, Rack::Static,
                                   urls: STATIC_URLS, root: Engine.root.join('app/stylesheets'),
                                   header_rules: STATIC_HEADERS
    end
  end
end
