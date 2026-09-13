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
    # Initializers all run before routes are drawn, so `recourses` exists in time.
    initializer 'recourse.routes' do
      ActionDispatch::Routing::Mapper.include Scopes, Routes
    end
  end
end
