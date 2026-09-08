# Reopened for the order a row reads in, which a table, a show page and a form all ask
# for the same way.
module Recourse
  # Which part of a row a column belongs to. What a column holds is the gem's to know
  # and where the schema put it is the host's, so both have a say: the kind picks the
  # band, and the order inside the band is the one the table already has. Extended onto
  # `Recourse`, so this is `Recourse.ordered` wherever it is called from.
  module Columns
    # The bands, in the order a row reads. What kind of row this is and what state it is
    # in, whose it is, what it says, its flags, the long values a narrow column suits
    # least, when it happened, the two Rails keeps — and last of all the counts, which
    # say nothing about the row itself, only how much hangs off it. So they close the
    # row at the far edge rather than opening it beside the buttons they resemble.
    #
    # A flag follows what the row says rather than leading it. A yes or a no is narrow
    # enough to have led on width alone, but it reads as a note *about* the row, and a
    # reader scanning a table is looking for the name it belongs to first.
    BANDS = %i[state reference scalar boolean long date timestamp counter].freeze

    # Values that are paragraphs rather than words, under every name an adapter has for
    # them: PostgreSQL reports `jsonb` where SQLite and MySQL report `json`.
    LONG_KINDS = %i[text json jsonb].freeze

    # And the ones that are a point in time, whichever part of one they keep.
    DATE_KINDS = %i[date datetime time].freeze

    # Whether a column holds a list of values rather than one. A PostgreSQL array
    # reports a type wrapping a subtype, and so does a `serialize` of an Array; asked
    # that way rather than by an adapter's own class, which only exists where that
    # adapter is loaded. But wrapping a subtype is not enough on its own: an enum and a
    # range always answered the same way, and since Rails 8.2 so does every decorator
    # a column may wear — time zone conversion on a timestamp, `normalizes`, a lock. What
    # sets a list apart is that its value is changed in place, which `Mutable` marks and
    # none of those are.
    def list_column?(model, column)
      type = model.type_for_attribute column

      type.respond_to?(:subtype) && type.is_a?(ActiveModel::Type::Helpers::Mutable)
    end

    # The columns of a model in the order a row reads them, given whichever of them the
    # caller is drawing. Grouped rather than sorted: `group_by` keeps the order it was
    # given inside each group, which is what leaves an order the schema already carries
    # standing, and `sort_by` would not — Ruby's sort is not stable.
    def ordered(model, names)
      keys = reference_keys model

      names.group_by { |name| BANDS.index band(model, name, keys) }.sort.flat_map(&:last)
    end

  private

    # Asked in the order that settles it. A counter is one whatever it is stored as; the
    # column Rails keeps a subclass in says what kind of row this is, as an enum says
    # what state it is in; and a key is an integer, so it has to be recognised as a key
    # before its type is asked about at all.
    def band(model, name, keys)
      return :counter if model.recourse_counters.key? name
      return :state if name == model.inheritance_column || model.defined_enums.key?(name)
      return :timestamp if TIMESTAMPS.include? name
      return :reference if keys.include? name

      band_of model.type_for_attribute(name).type
    end

    def band_of(kind)
      return :boolean if kind == :boolean
      return :long if LONG_KINDS.include? kind
      return :date if DATE_KINDS.include? kind

      :scalar
    end

    def reference_keys(model)
      model.recourse_references.map { |reference| reference.foreign_key.to_s }
    end
  end

  extend Columns
end
