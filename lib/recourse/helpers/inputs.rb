module Recourse
  module Helpers
    # The control an attribute is typed into, chosen by what the attribute holds.
    module Inputs
      # Numbers a field takes whole. A month and a year are counted in no smaller unit
      # than themselves, so neither admits the decimals a `step` would otherwise allow.
      WHOLE_KINDS = %i[integer month year].freeze

    private

      # A field for a column whose kind is what decides it, the fallback being a text
      # box for anything that never said what it holds. The checkbox is handed one
      # option by name rather than the whole hash: the rest is `maxlength`, `pattern`,
      # `placeholder`, `inputmode` and `required`, none of which a box that is either
      # ticked or not has any use for.
      def kind_field(form, column, **options)
        kind = attribute_kind column
        return numeric_field(form, column, kind, **options) if numeric_kind? kind
        return menu_field form, column, kind if menu_kind? kind

        case kind
        when :boolean then tag.div form.check_box(column, class: 'check', aria: options[:aria])
        when :date then form.date_field(column, **options)
        when :datetime then form.datetime_local_field(column, **options)
        when :text, :list then area_field(form, column, kind, **options)
        else form.text_field(column, **options)
        end
      end

      # A list is typed one value to a line, a newline being the one separator a value
      # cannot itself contain. Handed its value, since a box left to read an Array off
      # the record would print the brackets.
      def area_field(form, column, kind, **)
        return form.text_area(column, **, rows: 1) if kind == :text

        values = Array form.object&.attributes&.fetch(column, nil)
        form.text_area column, **, rows: 3, value: values.join("\n")
      end

      # `step` is what limits a field to whole numbers, and what admits the decimals a
      # column keeps: two of them for a `scale: 2`, any number at all for a float,
      # which says how precise it is nowhere.
      def numeric_field(form, column, kind, **)
        return form.telephone_field(column, **) if kind == :phone
        return adorned_field(form, column, **) if %i[monetary percentage].include? kind

        form.number_field(column, **, **step_options(column, kind))
      end

      def step_options(column, kind)
        return { step: 1 } if WHOLE_KINDS.include? kind

        scale = attribute_scale column
        return { step: :any } unless scale

        { step: 10.0**-scale, max: digit_ceiling(column, scale) }
      end

      # Bootstrap adorns a control by wrapping it: the border and the padding are the
      # wrapper's, the input inside is a `.form-ghost` with neither, and
      # `.form-adorn-end` is what moves the unit to the far side of it.
      def adorned_field(form, column, **options)
        end_ = attribute_kind(column) == :percentage
        classes = ['form-control form-adorn d-flex', ('form-adorn-end' if end_)].compact
        unit = tag.span adorn_unit(end_), class: 'form-adorn-text'

        tag.div class: classes.join(' ') do
          safe_join [unit, adorned_input(form, column, **options)]
        end
      end

      def adorned_input(form, column, **)
        form.number_field(column, **, class: 'form-ghost',
                                      **step_options(column, attribute_type(column)))
      end

      # The currency the app counts in, which is what its number formats already say.
      def adorn_unit(percentage)
        percentage ? '%' : I18n.t('number.currency.format.unit', default: '$')
      end

      # The largest value the column has room for: `precision: 4, scale: 2` keeps four
      # digits of which two are decimals, so 99.99 and nothing above it.
      def digit_ceiling(column, scale)
        precision = attribute_precision column
        return unless precision

        (10.0**(precision - scale)) - (10.0**-scale)
      end
    end
  end
end
