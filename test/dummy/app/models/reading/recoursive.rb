class Reading
  # Labels a reading by its id, since a depth is a measurement rather than a name and
  # no other column here says which reading this is. That is the point of the table:
  # an id is not a word, so a `cont` against it would match nothing.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :id

      # Deepest first, and the readings with no depth recorded after every one that has.
      def recourse_order = { depth: :desc }

      # The one table whose keys are named as a hash rather than as a list — the shape
      # a host writes where its own row reads through a key, as this one could read the
      # sensor the reading before it was taken by. `includes` takes either, so what the
      # table's version is read off has to follow either.
      def recourse_includes = [:grade, :sensor, { previous_reading: :sensor }]
    end
  end
end
