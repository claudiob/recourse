require 'rails/generators/rails/controller/controller_generator'

module Recourse
  module Generators
    # What `rails generate recourse` writes a controller with: Rails' own generator,
    # answering to a different parent class. A controller of the host's own is
    # exactly what `Controllers.define_missing` steps aside for, so the
    # `ApplicationController` one `resource` writes would leave the resource with no
    # actions at all — the opposite of what generating it was for.
    class ControllerGenerator < Rails::Generators::ControllerGenerator
      # The template is the parent's `controller.rb`, and a source root is per-class
      # rather than inherited: without this line there is nothing to render.
      source_root Rails::Generators::ControllerGenerator.source_root

      class_option :parent, type: :string, default: 'RecoursesController',
                            desc: 'The parent class for the generated controller'
    end
  end
end
