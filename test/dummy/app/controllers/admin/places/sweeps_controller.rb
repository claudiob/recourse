module Admin
  module Places
    # A verb with no model behind it, which is what most bare actions are.
    class SweepsController < RecoursesController
      def create
        place = Place.find params.expect(:place_id)
        # A sweep of a place is a verb this app has nothing behind, so saying it ran is
        # the whole of what it does — and a button that reports nothing at all reads as
        # one that is broken.
        flash.notice = "Swept #{place.name}"
        redirect_to place_path(place), status: :see_other
      end
    end
  end
end
