module Recourse
  module Helpers
    # Turns a model's validators into the HTML that constrains a form field.
    module Constraints
      # Shown for a field whose shape has one canonical example.
      SAMPLE_PLACEHOLDERS = { 'email' => 'michael@example.com' }.freeze

      # Hands a phone field to the controller that decides its shape: the separators as it
      # is typed, and the pattern, placeholder and title the field is left without here.
      PHONE_CONTROLLER = {
        controller: 'phone', action: 'keydown->phone#down input->phone#input',
      }.freeze

    private

      # Browser-side constraints, every one read from the validators of `model` —
      # which is the page's model unless a field asks about another one's attribute.
      def field_html(column, type = nil, model = resource_model)
        key = (type || column).to_s
        pattern = column_pattern(model, column) unless key == 'phone'

        {
          maxlength: length_option(model, column, :maximum),
          minlength: length_option(model, column, :minimum), pattern:,
          title: title(key, pattern), placeholder: placeholder(model, column, type),
          inputmode: (:numeric if numeric? model, column, pattern),
          required: (true if required? model, column),
          data: (PHONE_CONTROLLER if key == 'phone'),
        }.compact
      end

      # The canonical sample where the field has one, so the title agrees with the
      # placeholder; otherwise a shape read off the pattern itself.
      def title(key, pattern)
        return unless pattern

        t 'recourse.format', example: SAMPLE_PLACEHOLDERS[key] || pattern_example(pattern)
      end

      def length_option(model, column, bound)
        length_options(model, column).values_at(bound, :is).compact.first
      end

      def length_options(model, column)
        validator(model, column, ActiveModel::Validations::LengthValidator)&.options || {}
      end

      # An HTML pattern is anchored already, so \A and \z come off the Ruby one.
      def column_pattern(model, column)
        shape = validator model, column, ActiveModel::Validations::FormatValidator
        regexp = shape&.options&.dig :with
        return unless regexp

        regexp.source.delete_prefix('\A').delete_suffix '\z'
      end

      # An explicit type states what the field is, so it picks the sample; without
      # one a required field shows the shape it expects and an optional one says so.
      def placeholder(model, column, type)
        sample = SAMPLE_PLACEHOLDERS[(type || column).to_s]
        return sample if sample && (type || required?(model, column))

        t 'recourse.optional' unless required? model, column
      end

      def required?(model, column)
        Recourse.validated_names(column).any? { |name| presence_validated? model, name }
      end

      def presence_validated?(model, attribute)
        validator(model, attribute, ActiveModel::Validations::PresenceValidator).present?
      end

      def numeric?(model, column, pattern)
        digits_only?(pattern) ||
          validator(model, column, ActiveModel::Validations::NumericalityValidator).present?
      end

      # `\d` carries a letter, so it has to go before looking for real ones.
      def digits_only?(pattern)
        pattern.present? && !pattern.gsub('\d', '').match?(/[A-Za-z]/)
      end

      def validator(model, attribute, kind)
        model.validators_on(attribute).find { |one| one.is_a? kind }
      end
    end
  end
end
