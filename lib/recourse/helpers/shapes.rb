module Recourse
  module Helpers
    # The shapes one page of rows can be read in — a table, a map of where they are, a
    # calendar of when they are — and the links from the one showing to the others.
    module Shapes
    private

      # Whether this page is the map rather than the table.
      def map_view? = request.format.map?

      # Whether this page is the calendar rather than the table.
      def calendar_view? = request.format.cal?

      # What this page can be, by the format each shape is addressed as and the word
      # the link to it reads: the table every model has, and whichever of the other
      # two the model's own columns earn.
      def view_shapes
        model = resource_model
        shapes = { html: 'recourse.as_table' }
        shapes[:map] = 'recourse.as_map' if Recourse.mappable? model
        shapes[:cal] = 'recourse.as_calendar' if Recourse.calendarable? model

        shapes
      end

      # A link to each shape the page is not in, carrying the query it was asked with —
      # the search, the sort and the page — so another shape shows the rows the table
      # did. The week stays behind: only a calendar has one, and a calendar reached
      # from the table opens on this week.
      def view_links
        shapes = view_shapes
        query = request.query_parameters.except 'week'

        # The table is the page at its own address, which is the one shape asked for by
        # carrying no extension at all.
        shapes.except(request.format.symbol).map do |shape, key|
          link_to t(key), url_for(query.merge(format: (shape unless shape == :html)))
        end
      end
    end
  end
end
