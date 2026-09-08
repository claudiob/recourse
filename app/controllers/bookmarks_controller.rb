# The superclass every bookmark controller gets. A host defines this class itself —
# its `app/controllers` comes first — to write the row its own way, the same way it
# redefines `RecoursesController` to guard every screen.
class BookmarksController < Recourse::BookmarksController
  # Empty on purpose: the behavior is the base class, so a host redefining this one
  # loses none of it.
end
