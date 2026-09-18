module Admin
  module Places
    # A singular resource the gem would resolve by itself, answered here anyway: an
    # override still wins, which is what leaves a host free to find a record the
    # parent names no association for.
    class ZipsController < RecoursesController
    private

      def find_resource
        assign @recourse_parent.zip
      end
    end
  end
end
