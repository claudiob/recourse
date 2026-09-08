require_relative 'files'

module Recourse
  module Generators
    # What a generated column says, said again where Active Record can read it.
    # Every rule the gem draws on a page comes from a validator and never from the
    # schema, so a constraint the database keeps alone is one no field can show and
    # no form can report. Private for the reason `Seeds` is.
    module Validations
      include Files

      # `limit` counts characters for these two and bytes for everything else —
      # `age:integer{2}` asks for a two-byte column, not a two-digit number — so
      # only these carry a limit a length validator may repeat.
      MEASURED_TYPES = %i[string text].freeze

    private

      # Every line the attributes earn, appended to the model in one go.
      def declare_validations
        return say_status :skip, "#{model_file} does not exist" unless exist? model_file

        lines = attributes.filter_map { |attribute| validation_line attribute }
        return if lines.empty?

        inject_into_file model_file, validation_block(lines), before: /^end\n/
      end

      # One line per attribute that earns one, or nothing at all.
      def validation_line(attribute)
        options = [
          presence_validation(attribute), length_validation(attribute),
          uniqueness_validation(attribute),
        ].compact
        return if options.empty?

        "  validates :#{attribute.column_name}, #{options.join ', '}\n"
      end

      # A blank line where the model template already wrote one — the associations a
      # `references` earns — and none where the class it wrote is still empty.
      def validation_block(lines)
        spacer = "\n" unless read(model_file).match?(/^class .*\nend$/)

        "#{spacer}#{lines.join}"
      end

      # `title:string!` is what writes `null: false`, and a boolean says the same
      # thing another way: `presence` rejects `false` along with nil, so a column
      # that has to hold one of the two names them instead. A reference is left
      # alone — Rails' own `belongs_to` already requires what it points at.
      def presence_validation(attribute)
        return if attribute.reference? || attribute.attr_options[:null] != false
        return 'inclusion: { in: [true, false] }' if attribute.type == :boolean

        'presence: true'
      end

      # `name:string{100}` caps the column, and `maxlength` in the browser is read
      # from the validator alone — the schema is never asked what a field may hold.
      def length_validation(attribute)
        limit = attribute.attr_options[:limit]
        return unless limit && MEASURED_TYPES.include?(attribute.type)

        "length: { maximum: #{limit} }"
      end

      # `email:string:uniq` indexes the column uniquely, and the validator is what
      # turns a second one into a message on the field rather than a 500 from the
      # adapter. Not for a polymorphic reference, whose uniqueness is over two
      # columns and needs a `scope:` only the host can name.
      def uniqueness_validation(attribute)
        'uniqueness: true' if attribute.has_uniq_index? && !attribute.polymorphic?
      end
    end
  end
end
