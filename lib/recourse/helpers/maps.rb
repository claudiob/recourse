module Recourse
  module Helpers
    # The map a table of places is read as. Which shapes a page has and the links
    # between them are `Shapes`, since a map is only one of them.
    module Maps
    private

      # What the map controller needs: the key and the map from the host's credentials,
      # and this page's rows as the places or the points they keep.
      def map_data(recourses)
        keys = Recourse.google_maps

        { controller: 'map', map_key_value: keys[:api_key], map_id_value: keys[:map_id] }
          .merge map_rows(recourses)
      end

      # The places, with the layer they are areas on — pins where the model is no geography
      # — or the points, where a model keeps no place. Each carries where its row leads and
      # what it is called, so a pin or an area is clicked through to the record the way the
      # row's own link in the table is.
      def map_rows(recourses)
        return { map_points_value: map_points(recourses) } unless Recourse.placed? resource_model

        {
          map_boundary_value: Recourse.boundary(resource_model)&.to_s&.upcase,
          map_places_value: map_places(recourses),
        }
      end

      # Each place as `[id, href, title]`, for a row that names one.
      def map_places(recourses)
        recourses.filter_map do |one|
          place = one.attributes[Recourse::PLACE_COLUMN]
          [place, *map_lead(one)] if place
        end
      end

      # Each point as `[lat, lng, href, title]`. Only a row with both halves is a point; one
      # with either missing is nowhere.
      def map_points(recourses)
        recourses.filter_map do |one|
          point = one.attributes.values_at(*Recourse::POINT_COLUMNS)
          [*point.map(&:to_f), *map_lead(one)] if point.all?
        end
      end

      # Where a row's pin leads, the record's own page wherever one is routed, and what the
      # pin says on hover: nothing to lead to where no page is.
      def map_lead(record) = [resource_action_path(:show, record), Recourse.record_title(record)]
    end
  end
end
