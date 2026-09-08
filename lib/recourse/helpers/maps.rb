module Recourse
  module Helpers
    # The map a table of places is read as, and the link under either that leads to
    # the other.
    module Maps
    private

      # Whether this page is the map rather than the table.
      def map_view? = request.format.map?

      # The link under the rows to the other shape of the page, or nothing where the
      # model keeps no place ID to draw one by. The query goes with it — the search, the
      # sort and the page — so the map shows the rows the table did.
      def view_link
        return unless Recourse.mappable? resource_model

        params = request.query_parameters
        return link_to t('recourse.as_table'), url_for(params.merge(format: nil)) if map_view?

        link_to t('recourse.as_map'), url_for(params.merge(format: :map))
      end

      # What the map controller needs: the key and the map from the host's credentials,
      # and the places on this page — a page of the table is a page of the map.
      def map_data(recourses)
        keys = Recourse.google_maps

        {
          controller: 'map', map_key_value: keys[:api_key], map_id_value: keys[:county_map_id],
          map_places_value: recourses.map { |one| one.attributes[Recourse::PLACE_COLUMN] }.compact,
        }
      end
    end
  end
end
