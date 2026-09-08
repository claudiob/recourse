module Recourse
  module Helpers
    # What an attribute holds, which is the one question a value and a field are both
    # answers to.
    module Kinds
      # Numbers, which differ by what they are of rather than by how they are stored.
      NUMERIC_KINDS = %i[integer decimal float phone monetary percentage month year].freeze

      # The two of those that count nothing, and so are neither delimited nor rounded:
      # a month is a word for one and a year is when something happened.
      UNCOUNTED_KINDS = %i[month year].freeze

      # The kinds whose values are a list known before anybody types: an enum's are the
      # model's own, and a time zone's are Rails'. Each is drawn as the menu of them.
      MENU_KINDS = %i[enum time_zone].freeze

      # A payload, under both names an adapter has for one: SQLite and MySQL report a
      # JSON column as `json`, and PostgreSQL's own type reports `jsonb`. Two names for
      # the thing a page does the same with, so the gem asks for either.
      JSON_KINDS = %i[json jsonb].freeze

    private

      # Whether a kind is one of those, which is what both pages branch on first.
      def numeric_kind?(kind) = NUMERIC_KINDS.include?(kind)

      def menu_kind?(kind) = MENU_KINDS.include?(kind)

      # A month read as the word for one, and a year as the digits it is. Neither counts
      # anything, so neither wears the delimiter a quantity does: 2,025 is a number of
      # things, and 2025 is when they happened.
      def uncounted(kind, value)
        return unless value

        kind == :month ? Date::MONTHNAMES[value] : value.to_s
      end

      # Asked in the order that settles it. A counter cache is a counter whatever its
      # column says, since no page may show one and no form may set one; an enum is
      # one however it is stored, and is asked before a list because Rails wraps a
      # column's type to map an enum's words onto it, which reads as a list otherwise;
      # a phone is a phone by its name, the convention the placeholders and the pattern
      # already follow; and everything else is the type the attribute itself reports —
      # `:monetary` included, where a host has registered a type that says so.
      def attribute_kind(column)
        return :counter if resource_model.recourse_counters.key? column
        return :enum if resource_model.defined_enums.key? column
        return :list if Recourse.list_column? resource_model, column
        return :phone if column == 'phone'

        attribute_type column
      end

      # The model's own attribute type, so an `attribute` override still counts and
      # `columns_hash` is never asked.
      def attribute_type(column)
        resource_model.type_for_attribute(column).type
      end

      # Columns holding JSON, under whichever name this adapter reports. A payload is a
      # service's answer kept whole — machinery rather than anything a row is about —
      # and one of them is as wide as a page, so no table draws one until a model names
      # it back. Asked through `type_for_attribute` like every other kind, so an
      # `attribute` override counts here too.
      def json_columns
        resource_model.column_names.select { |column| JSON_KINDS.include? attribute_type(column) }
      end

      # How many decimals the attribute keeps, and how many digits in all. Read from
      # the type rather than the column, and nil for anything that never said.
      def attribute_scale(column)
        resource_model.type_for_attribute(column).scale
      end

      # Total digits the attribute holds, the scale included.
      def attribute_precision(column)
        resource_model.type_for_attribute(column).precision
      end

      # What to round a number to, where the attribute says how much it keeps.
      def precision_option(column)
        scale = attribute_scale column
        scale ? { precision: scale } : {}
      end
    end
  end
end
