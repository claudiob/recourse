module Recourse
  # What the routes DSL reads back out of the Mapper as it draws, and what it records
  # from that: the module a resource is being declared in, and the resource a block is
  # nesting under.
  module Scopes
  private

    # The Mapper keeps its scope in an internal frame with no reader, so the two
    # facts this DSL needs — the module being drawn in, and the resource a block
    # nests under — are read in these two methods and nowhere else: a Rails
    # upgrade that moves the frame edits one file, twice.
    def current_module
      @scope[:module]
    end

    def parent_resource
      @scope[:scope_level_resource]
    end

    def record_declaration(path)
      # A nested resource is reached through its parent rather than the sidebar,
      # so it is recorded under the parent's path — that order is its tabs' order.
      return Recourse.declare path unless parent_resource

      Recourse.nest parent_path, path
    end

    # The parent's own controller path: the module being drawn in, cut off after the
    # parent resource's own segment, so a `namespace` between the two is left out
    # rather than mistaken for the parent itself.
    def parent_path
      parts = current_module.to_s.split '/'

      parts[0..parts.rindex(parent_resource.name)].join '/'
    end
  end
end
