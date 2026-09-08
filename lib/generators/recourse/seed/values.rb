module Recourse
  module Generators
    # What one seed cell is worth: a Ruby literal of the column's own kind, drawn
    # at random while generating — the written file then never changes between
    # `db:seed` runs, which is what keeps `find_or_create_by!` finding its rows.
    # Private for the reason `Seeds` is.
    module Values
      # A value of each kind of column, random within a shape the column accepts.
      # A decimal stays under ten, so any precision two steps over its scale fits.
      VALUES = {
        integer: -> { rand(100).to_s },
        float: -> { "#{rand 100}.#{rand 10}" },
        decimal: -> { "#{rand 1..9}.#{rand 10}" },
        boolean: -> { [true, false].sample.to_s },
        date: -> { "Date.current - #{rand 365}" },
        datetime: -> { "Time.current - #{rand 1..9000}.hours" },
      }.freeze

    private

      def seed_pair(column, number)
        name, row = @facts.reference column
        return "#{name}: #{row}" if name

        "#{column}: #{seed_value column, number}"
      end

      # A Ruby literal for one cell: an enum cycles the words it admits, and
      # everything else is `VALUES`' business — a kind it has no entry for reading
      # as a string, which is what every remaining column holds.
      def seed_value(column, number)
        words = @facts.enum column
        return ":#{words.keys[(number - 1) % words.size]}" if words

        VALUES.fetch(@facts.kind(column)) { -> { seed_string column } }.call
      end
    end
  end
end
