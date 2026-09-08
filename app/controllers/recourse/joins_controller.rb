module Recourse
  # The row behind an Add and a Remove: a page listing one side of a many-to-many
  # writes the join a row at a time, and never reads it. Both records are named by
  # the path, so there is nothing to submit and nothing to look up.
  class JoinsController < ::RecoursesController
    # Joins the two the path names, and comes back to the listing that asked.
    def create
      resource_class.create! join_columns
      redirect_back fallback_location: listing_url, status: :see_other
    end

    # And drops it. `destroy_all` rather than `destroy!`: a unique index is what
    # keeps this to one row, and a page should not fail for having none.
    def destroy
      resource_class.where(join_columns).destroy_all
      redirect_back fallback_location: listing_url, status: :see_other
    end

  private

    # Both keys the path carries: the record the listing hangs off, and the one the
    # button sat beside. Read off the join's own `belongs_to`, so a join whose keys
    # are named unusually needs nothing said about it.
    def join_columns
      resource_class.recourse_references.to_h do |association|
        [association.foreign_key, params.expect(:"#{association.name}_id")]
      end
    end

    # Where the button was, for a request that arrived without a referer.
    def listing_url
      listing = Recourse.parent_of controller_path
      parent = Recourse.parent_of(listing).split('/').last.singularize

      url_for controller: "/#{listing}", action: :index,
              "#{parent}_id": params.expect(:"#{parent}_id")
    end
  end
end
