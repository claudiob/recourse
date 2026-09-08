module Recourse
  # The place one row holds in a table somebody arranged: written by a drag or by the
  # arrows beside the row, and never read back here. The path names the row and the
  # route names the rows it is counted among, so a position is all there is to submit.
  class PositionsController < ::RecoursesController
    # `update` is a member action everywhere else, so the inherited callback would
    # look for an `:id` a singular resource never carries.
    skip_before_action :find_resource

    # Puts the row the path names where the request says, among the rows the route
    # named, and answers with as little as the caller can do with.
    def update
      positioning = Positioning.new recourse_relation, arranged_column
      positioning.move moved_record, params.expect(:position)
      answer
    end

  private

    # The model this arranges, read off the listing the route was nested under rather
    # than off this controller's own name, which is always `positions`.
    def resource_class
      Recourse.model listing_path
    end

    def moved_record
      resource_class.find params.expect(:"#{listing_name}_id")
    end

    # A table nobody arranges draws no handle, so the only way here is by hand — which
    # earns a 404 rather than a 500 from somewhere below.
    def arranged_column
      raise ActiveRecord::RecordNotFound unless arranged?

      @recourse_position
    end

    # Where the two paths part, as the bookmark square parts them: a drag is answered
    # with nothing at all, since a flash it never renders would keep until the next
    # page and announce a move made several pages ago.
    def answer
      return head :no_content unless request.format.html?

      flash.notice = t 'recourse.position_updated'
      redirect_back fallback_location: listing_url, status: :see_other
    end

    # One segment up, which is where the routes drew it — the gem draws this path
    # itself, so unlike a host's nesting there is nothing to look up.
    def listing_path
      controller_path.rpartition('/').first
    end

    def listing_name
      listing_path.split('/').last.singularize
    end

    # Where the table was, for a request that arrived without a referer.
    def listing_url
      url_for controller: "/#{listing_path}", action: :index
    end
  end
end
