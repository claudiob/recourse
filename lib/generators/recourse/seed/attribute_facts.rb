module Recourse
  module Generators
    # The same questions `ModelFacts` answers, asked of a resource being generated
    # rather than of one already migrated: `rails generate recourse` writes its seed
    # file before the table exists, so the attributes it was handed are all there is
    # to read. One engine writes both files; only where the facts come from differs.
    class AttributeFacts
      # What the file is called, and the class the rows are made of.
      attr_reader :plural, :class_name

      # Takes the attributes the generator parsed, and the names it will write them
      # under, since a generator keeps both of those to itself.
      def initialize(attributes, plural:, class_name:)
        @attributes = attributes
        @plural = plural
        @class_name = class_name
      end

      # Columns a row may fill, a reference reading as the key it writes.
      def columns = @attributes.map(&:column_name)

      # What a row cannot save without: the `!` that wrote `null: false`, and every
      # reference, since `belongs_to` requires what it points at.
      def required?(column)
        one = attribute column

        one.attr_options[:null] == false || one.required?
      end

      # Nothing: `enum` is a word a model says, and this model has said nothing yet.
      def enum(_column) = nil

      # The type as it was typed, which is already the name a value is drawn for.
      def kind(column) = attribute(column).type

      # The first row of what the key points at. Which row cannot be chosen here the
      # way `ModelFacts` chooses one: the table it would count may not be migrated.
      def reference(column)
        one = attribute column
        return unless one.reference?

        [one.name, "#{one.name.camelize}.first"]
      end

      # The limit the column was asked for, which is also the length validator
      # written beside it — the two say the same thing, so either bounds a string.
      def bounds(column)
        { limit: attribute(column).attr_options[:limit] }.compact
      end

    private

      def attribute(column)
        @attributes.find { |one| one.column_name == column }
      end
    end
  end
end
