module Recourse
  module Helpers
    # Reads an example of an accepted value off the pattern that accepts it.
    module Examples
      # One token of a pattern and the `{n}` that may repeat it, so `\d{5}` reads
      # as a single digit five times over rather than as five separate characters.
      # `\d`, a bracket class and a literal are all it knows; nothing else is used.
      PATTERN_TOKENS = /(\\d|\[[^\]]*\]|[^{])(?:\{(\d+),?\d*\})?/

      # A token that is a bracket class, so `[2-9]` counts as one rather than five.
      CLASS_TOKEN = /\A\[/

      # First character a bracket class offers, past the bracket and any negation.
      CLASS_SAMPLE = /[^\[^]/

    private

      # What the pattern accepts, so a field can name the shape it wants instead of
      # only reporting that what was typed is wrong.
      def pattern_example(pattern)
        tokens = pattern.scan PATTERN_TOKENS

        tokens.map { |token, count| pattern_sample(token) * (count || 1).to_i }.join
      end

      def pattern_sample(token)
        case token
        when '\d' then '0'
        when CLASS_TOKEN then token[CLASS_SAMPLE]
        else token
        end
      end
    end
  end
end
