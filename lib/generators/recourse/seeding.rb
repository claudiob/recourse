require_relative 'seed/attribute_facts'
require_relative 'seed/rows'
require_relative 'seed/shapes'
require_relative 'seed/texts'
require_relative 'seed/values'

module Recourse
  module Generators
    # The seed file `rails generate recourse` writes, which is the file
    # `recourse:seed` writes: one engine, reading the attributes just parsed rather
    # than a table that does not exist yet. Private for the reason `Rows` is.
    module Seeding
      include Rows, Shapes, Texts, Values

    private

      def write_seed_file
        @facts = AttributeFacts.new attributes, plural: table_name, class_name: class_name
        template 'seeds.rb', File.join('db/seeds', "#{table_name}.rb")
        load_seed_files
      end
    end
  end
end
