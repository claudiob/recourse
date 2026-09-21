module Admin
  module Places
    # Where the places came from is this app's to know, so the fetch is its to write.
    class RetrievalsController < RecoursesController
      def create
        flash.notice = 'Fetching places'
        redirect_to places_path, status: :see_other
      end
    end
  end
end
