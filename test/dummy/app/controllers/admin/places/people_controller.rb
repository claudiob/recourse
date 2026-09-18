module Admin
  module Places
    # A singular resource over a record the parent may not have: the `belongs_to` is
    # optional, so what this finds is sometimes nothing, and the page says so.
    class PeopleController < RecoursesController
    private

      def find_resource
        assign @recourse_parent.person
      end
    end
  end
end
