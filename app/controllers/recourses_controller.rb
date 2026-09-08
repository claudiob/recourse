# The superclass every recoursed controller gets, and what puts its templates
# under `recourses/`. A host defines this class itself — its `app/controllers`
# comes first — to put a `before_action` of its own above every screen.
class RecoursesController < Recourse::BaseController
  # Empty on purpose: the behavior is the base class, so a host redefining this
  # one loses none of it.
end
