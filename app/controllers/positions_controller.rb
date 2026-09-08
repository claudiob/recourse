# The superclass every position controller gets. A host defines this class itself —
# its `app/controllers` comes first — to move a row its own way, the same way it
# redefines `RecoursesController` to guard every screen.
class PositionsController < Recourse::PositionsController
  # Empty on purpose: the behavior is the base class, so a host redefining this one
  # loses none of it.
end
