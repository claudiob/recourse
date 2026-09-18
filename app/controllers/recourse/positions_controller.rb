module Recourse
  # The place one row holds in a table somebody arranged: written by a drag, and never
  # read back here. The path names the row and the route names the rows it is counted
  # among, so a position is all there is to submit.
  class PositionsController < ::RecoursesController
    # `update` is a member action everywhere else, so the inherited callback would
    # look for an `:id` a singular resource never carries.
    skip_before_action :find_resource

    # Puts the row the path names where the request says, among the rows the route
    # named, and answers with as little as the caller can do with: a drag is answered
    # with nothing at all, the row being already where it was dropped, and redrawing
    # the table under the cursor that dropped it is what this avoids.
    def update
      positioning = Positioning.new recourse_relation, arranged_column
      positioning.move moved_record, params.expect(:position)

      head :no_content
    end

  private

    # The model this arranges, read off the listing the route was nested under rather
    # than off this controller's own name, which is always `positions`.
    def recourse_model = Recourse.model(listing_path)

    def moved_record = resource_class.find(params.expect(:"#{listing_name}_id"))

    # A table nobody arranges draws no handle, so the only way here is by hand — which
    # earns a 404 rather than a 500 from somewhere below.
    def arranged_column
      raise ActiveRecord::RecordNotFound unless arranged?

      @recourse_position
    end

    # One segment up, which is where the routes drew it — the gem draws this path
    # itself, so unlike a host's nesting there is nothing to look up.
    def listing_path = controller_path.rpartition('/').first

    def listing_name = listing_path.split('/').last.singularize
  end
end
