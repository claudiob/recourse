# A module to manage administered resources.
module Recourse
  # Makes Recourse methods like `recourses` available in config/routes.rb
  class Engine < ::Rails::Engine
    config.to_prepare do
      require 'recourse/routing'
      require 'recourse/recoursive'
      require 'recourse/searchable'
    end
  end
end
