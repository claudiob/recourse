module Recourse
  module Generators
    # What one model's seed rows are made of: hashes mixing which optional
    # attributes are filled. Private for the reason `Seeds` is.
    module Rows
      # How many rows each file holds: the first bare, the last full, and the rest
      # cycling through combinations of the optional attributes.
      ROWS = 25

    private

      # One `key: value` string per row, ready for a hash literal.
      def seed_rows
        (1..ROWS).map do |number|
          seed_columns(number).map { |column| seed_pair column, number }.join ', '
        end
      end

      # Which columns row `number` fills: every required one, plus the optional
      # ones whose bit is set in the row's own number — so the combinations differ
      # row to row, the first row is the bare minimum and the last fills everything.
      def seed_columns(number)
        optionals = seed_optionals
        return @facts.columns if number == ROWS

        @facts.columns.select do |column|
          !optionals.include?(column) || (number - 1)[optionals.index(column)] == 1
        end
      end

      def seed_optionals
        @facts.columns.reject { |column| @facts.required? column }
      end
    end
  end
end
