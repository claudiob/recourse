# Reopened for what the routes file said, which several helpers each need read back.
module Recourse
  # What the routes file said, remembered: which resources were drawn, which were
  # nested under which, and which listing edits a join rather than only reading one.
  # Extended onto `Recourse`, so every one of these is `Recourse.something` wherever
  # it is called from, and every ivar below is that module's own.
  module Registry
    # Records a resource as declared, keeping order and ignoring a repeated draw.
    def declare(name)
      @declared << name.to_s unless @declared.include? name.to_s
    end

    # Records a resource nested under a parent, in routes.rb order like the sidebar's
    # — which is what the parent record's tabs follow. Both sides are whole controller
    # paths, so a `namespace` drawn between the two is carried rather than guessed at.
    def nest(parent, child)
      children = @nested[parent.to_s] ||= []
      children << child.to_s unless children.include? child.to_s
      @parents[child.to_s] = parent.to_s
    end

    # The resources nested under one parent path, in the order they were drawn.
    def nested_under(parent)
      @nested.fetch parent.to_s, []
    end

    # The path a nested resource hangs off, or nil where it hangs off nothing. Read
    # back rather than chopped off the controller's own path: how many segments a
    # nesting added is something the routes knew and a path no longer says.
    def parent_of(child)
      @parents[child.to_s]
    end

    # Records the join a listing edits: `recourses :teams, through: :memberships` is
    # a page of every team with a membership to add or drop beside each one, rather
    # than a page of the teams a person is already on.
    def join(path, through)
      @joins[path.to_s] = through.to_s
    end

    # The join model a path edits, or nil where the page only lists. A model rather
    # than the word, so everything downstream asks it what its own keys are.
    def join_of(path)
      @joins[path.to_s]&.classify&.safe_constantize
    end
  end

  extend Registry
end
