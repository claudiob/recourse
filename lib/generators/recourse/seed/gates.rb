module Recourse
  module Generators
    # What stands between a row and saving, asked of the model being seeded: the
    # validators that reject nil, and the columns the database refuses NULL in.
    module Gates
      # Validators that reject nil, so a row cannot save without the attribute:
      # `inclusion: { in: [true, false] }` is how a required boolean is asked for.
      REQUIRING = [
        ActiveModel::Validations::PresenceValidator,
        ActiveModel::Validations::InclusionValidator,
      ].freeze

      # What the bare row cannot leave out: a column the model validates against nil,
      # or one the database refuses NULL in with no default. Both gates stand between
      # a row and saving, so both are asked.
      def required?(column)
        validated?(column) || constrained?(column)
      end

    private

      # What the model hides and something still insists on. Only its own columns:
      # `recourse_hidden` sits beside the inheritance column, which a table without
      # single table inheritance does not have.
      def insisted_on_columns
        hidden = Recourse.hidden_columns(@model) & @model.column_names

        hidden.select { |column| required? column }
      end

      def validated?(column)
        Recourse.validated_names(column).any? do |attribute|
          @model.validators_on(attribute).any? { |one| REQUIRING.any? { |kind| one.is_a? kind } }
        end
      end

      def constrained?(column)
        one = @model.columns_hash[column]

        !one.null && one.default.nil? && one.default_function.nil?
      end
    end
  end
end
