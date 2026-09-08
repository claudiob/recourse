class Place
  # Extends Place with the two things it keeps back, the two it asks to show, and the
  # one it says what it is for.
  module Recoursive
    extend ActiveSupport::Concern

    # SQLite keeps no column comments, so the dummy says by hand what a Postgres host's
    # schema would have said for it. One per kind of control, since what a note is tied
    # to is a different job under each: a box, a checkbox, a menu, and a key typed
    # rather than picked.
    COMMENTS = {
      'active' => 'Whether it takes bookings today',
      'capacity' => 'How many people fit at once',
      'status' => 'Where it stands right now',
      'zip_id' => 'The five digits, not the town',
    }.freeze

    class_methods do
      # `place` is a word Unicon has never heard of, and a circle is a poor thing to
      # head a column with. ZIP says nothing here on purpose, so the page it draws is
      # what the fallback looks like.
      def recourse_icon = :building

      # Indexed, so it would otherwise be searched, sorted and shown — which is what
      # makes it the honest test of a column a model simply does not want read out.
      def recourse_hidden = :webhook_url

      # Both: a place is a thing whose age is worth knowing, where a row written
      # once by a migration is not. Where they go is the table's business — last,
      # and created before updated — so the order named here says nothing.
      def recourse_displayed = %i[created_at updated_at]

      # Everything else falls through to the schema, which on this adapter answers
      # nothing at all.
      def recourse_comment(column) = COMMENTS[column] || super
    end
  end
end
