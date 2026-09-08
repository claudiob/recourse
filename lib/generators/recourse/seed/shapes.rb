module Recourse
  module Generators
    # What one string cell is: a shape the column's name promises — an address, a
    # phone — or free text, and never the same value twice in one column. Private
    # for the reason `Seeds` is.
    module Shapes
      # What an email's local part is made of, plain and lowercase: the shape has
      # to survive a format validator and `downcase: true` encryption unchanged.
      MAILBOX = [*'a'..'z', *'0'..'9'].freeze

    private

      # An email column gets an address, a phone column ten valid digits, and a
      # column named like an id — `uid`, `user_id` held as a string — digits
      # alone: the shapes a column's name promises. Everything else is words of a
      # random total length.
      def seed_string(column)
        seed_unique column do
          next seed_email if column.end_with? 'email'
          next seed_phone if column.end_with? 'phone'
          next seed_digits column if column.end_with? 'id'

          "'#{seed_words column}'"
        end
      end

      def seed_email
        "'#{Array.new(rand(4..10)) { MAILBOX.sample }.join}@example.com'"
      end

      def seed_phone
        "'555234#{format '%04d', rand(10_000)}'"
      end

      # As long as the column's own gates allow, like any other string.
      def seed_digits(column)
        "'#{Array.new(seed_length(column)) { rand 10 }.join}'"
      end

      # The same value twice would leave `find_or_create_by!` finding row one when
      # row two was meant, so a value is drawn again until it is new to its column.
      def seed_unique(column)
        @seed_taken ||= Hash.new { |hash, key| hash[key] = [] }
        taken = @seed_taken["#{@facts.class_name}/#{column}"]
        value = loop do
          candidate = yield
          break candidate unless taken.include? candidate
        end

        taken << value
        value
      end
    end
  end
end
