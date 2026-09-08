class Reading
  # Labels a reading by its id, since a depth is a measurement rather than a name and
  # no other column here says which reading this is. That is the point of the table:
  # an id is not a word, so a `cont` against it would match nothing.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :id
    end
  end
end
