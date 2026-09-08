# Reopened for what the routes file said, which several helpers each need read back.
module Recourse
  # What the routes file said, remembered: which resources were drawn, and which were
  # nested under which.
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
  end

  extend Registry
end
