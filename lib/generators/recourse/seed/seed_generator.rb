require 'rails/generators'

require_relative '../declared'
require_relative '../files'
require_relative '../loading'
require_relative 'model_facts'
require_relative 'rows'
require_relative 'shapes'
require_relative 'texts'
require_relative 'values'

module Recourse
  module Generators
    # `rails generate recourse:seed` — a seed file for every model `recourses`
    # serves, so every screen has rows to show and every nullable column is seen
    # both ways.
    class SeedGenerator < Rails::Generators::Base
      include Declared, Files, Loading, Rows, Shapes, Texts, Values

      # Templates live beside this class, which is also what tells the parent where
      # to read `--help` from: a USAGE one directory above the source root.
      source_root File.expand_path('templates', __dir__)

      # One file per model the routes declare, then the line `db/seeds.rb` loads
      # them all with. A file already written is left alone rather than offered for
      # overwriting: rows a host has since edited are the host's, and every run
      # names the same file for every model, so the question would be asked about
      # all of them to re-seed one. `--force` is how to ask for it back.
      def create_seed_files
        declared_models.each do |model|
          @facts = ModelFacts.new model
          path = File.join 'db/seeds', "#{@facts.plural}.rb"

          written?(path) ? say_status(:skip, path) : template('seeds.rb', path)
        end

        load_seed_files
      end

    private

      def written?(path)
        exist?(path) && !options[:force]
      end
    end
  end
end
