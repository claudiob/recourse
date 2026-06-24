# A module to manage administered resources.
module Recourse
  # Common acronyms
  ACRONYMS = %w[API CRM OpenAI PIN URL ZIP]

  # Makes Recourse methods like `recourses` available in config/routes.rb
  class Engine < ::Rails::Engine
    initializer 'recourse.inflections' do
      ActiveSupport::Inflector.inflections do |inflect|
        ACRONYMS.each { |acronym| inflect.acronym acronym }
      end
    end

    config.to_prepare do
      require 'recourse/routing'
      require 'recourse/recoursive'
      require 'recourse/searchable'
    end
  end
end
