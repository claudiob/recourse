module Recourse
  # The row behind a bookmark square: one record kept by whoever is looking, written
  # and dropped a row at a time and never read back here. The path names the record
  # and the host's own declaration names the viewer, so there is nothing to submit.
  class BookmarksController < ::RecoursesController
    # `destroy` is a member action everywhere else, so the inherited callback would
    # look for an `:id` a singular resource never carries.
    skip_before_action :find_resource

    # Keeps the record the path names. `find_or_create_by!` rather than `create!`:
    # the square answers before the request does, so a second click can arrive while
    # the first is still in flight, and twice kept is once kept.
    def create
      viewer_bookmarks.find_or_create_by! bookmark_key
      answer 'bookmark_added'
    end

    # And drops it. `destroy_all` rather than `destroy!` for the reason the join
    # gives: a unique index is what keeps this to one row, and a page should not
    # fail for having none.
    def destroy
      viewer_bookmarks.where(bookmark_key).destroy_all
      answer 'bookmark_removed'
    end

  private

    # The model this bookmarks, read off the listing the route was nested under
    # rather than off this controller's own name, which is always `bookmarks`.
    def resource_class
      Recourse.model listing_path
    end

    # A resource whose model keeps no bookmarks draws no square, so the only way here
    # is by hand — which earns a 404 rather than a 500 from somewhere below.
    def bookmark_reflection!
      bookmark_reflection || raise(ActiveRecord::RecordNotFound)
    end

    def bookmark_reflection
      Recourse.bookmarks_for resource_class
    end

    def viewer_bookmarks
      Recourse.bookmarks_of bookmark_reflection!
    end

    def bookmark_key
      { bookmark_reflection!.foreign_key => params.expect(:"#{listing_name}_id") }
    end

    # Where the two paths part. A background request is answered with nothing at all:
    # a flash it never renders would not be spent, and would surface as a toast on
    # the next page announcing a bookmark from several pages ago.
    def answer(message)
      return head :no_content unless request.format.html?

      flash.notice = t "recourse.#{message}"
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

    # Where the square was, for a request that arrived without a referer.
    def listing_url
      url_for controller: "/#{listing_path}", action: :index
    end
  end
end
