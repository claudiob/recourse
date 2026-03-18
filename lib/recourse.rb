require 'bh'
require 'pagy'
require 'ransack'
require 'recourse/engine'

# @see https://ddnexus.github.io/pagy/resources/initializer/
Pagy::OPTIONS[:limit] = 15
# Pagy.options[:limit] = 15

# A module to manage administered resources.
module Recourse
  # Return all the administered resources.
  mattr_reader :resources
  @@resources = {}
end
