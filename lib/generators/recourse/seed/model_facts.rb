require_relative 'gates'

module Recourse
  module Generators
    # What a seed file is written from, read off a model whose table is migrated —
    # what `recourse:seed` runs against. `rails generate recourse` has no table yet
    # and answers the same questions from its attributes, in `AttributeFacts`.
    class ModelFacts
      include Gates

      # What an app's own type is a kind of: a Monetary is a Decimal however it answers.
      KINDS = {
        ActiveModel::Type::Integer => :integer, ActiveModel::Type::Float => :float,
        ActiveModel::Type::Decimal => :decimal, ActiveModel::Type::Boolean => :boolean,
        ActiveModel::Type::Date => :date, ActiveModel::Type::DateTime => :datetime,
      }.freeze

      # What the file is called after, and the class the rows in it are made of.
      attr_reader :plural, :class_name

      # Takes the model being seeded, and answers for it from here on.
      def initialize(model)
        @model = model
        @plural = model.model_name.plural
        @class_name = model.name
      end

      # Columns a row may fill: the ones a form would offer, and any the model keeps
      # off its screens that a row still cannot save without — a seed's whole job is
      # a row that saves, and a hidden column the database insists on stands between
      # it and that. In the table's own order, so a file reads the way a schema does.
      def columns
        offered = Recourse.editable_columns(@model) + insisted_on_columns

        @model.column_names & offered
      end

      # The words an enum admits, for a column that is one.
      def enum(column) = @model.defined_enums[column]

      # The kind a value is drawn for. An attribute reporting a name of its own —
      # `:monetary` — is asked what it is a kind of; anything else answers for itself.
      def kind(column)
        type = @model.type_for_attribute column
        return type.type if KINDS.value? type.type

        KINDS.find { |klass, _| type.is_a? klass }&.last || type.type
      end

      # A random row of the other table, picked while generating: `db:seed` then
      # reads the same row every run, which a sample at seed time would not.
      def reference(column)
        association = belongs_to column
        return unless association

        rows = association.klass.count
        picked = ".offset(#{rand rows})" if rows > 1

        [association.name, "#{association.klass.name}#{picked}.first"]
      end

      # How long a string may be: the length validator's bounds, capped by the column's
      # SQL limit, since a value must fit past both. The schema is read for the reason
      # `constrained?` reads it — no validator speaks for a limit never stated.
      def bounds(column)
        length(column).slice(:is, :maximum, :minimum)
                      .merge(limit: @model.columns_hash[column]&.limit).compact
      end

    private

      def length(column)
        @model.validators_on(column).find do |one|
          one.is_a? ActiveModel::Validations::LengthValidator
        end&.options || {}
      end

      def belongs_to(column)
        @model.recourse_references
              .find { |association| association.foreign_key.to_s == column }
      end
    end
  end
end
