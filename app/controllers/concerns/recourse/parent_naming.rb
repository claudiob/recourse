module Recourse
  # Names the record a nested route sits under, so a host's own view can read it.
  module ParentNaming
  private

    # `/providers/5/openings` sets `@provider`, the way a hand-written controller would
    # -- the contract `ResourceResolution` already keeps for the record a page is about,
    # kept here for the one above it, and the reason a host needs no scoping concern of
    # its own to write a form or a row that names the parent.
    #
    # Named from the route rather than from the association, because the two need not
    # meet through a key: a page listing every vertical under a provider is nested by
    # the path alone, and no `belongs_to` joins the two. What `find_parent` resolved is
    # what gets the name, and only where it is the record the path names: a bare action
    # has no model, and a path may name a class that answers no queries.
    def name_parent
      path = Recourse.parent_of controller_path
      model = path && Recourse.model?(path)
      return unless model && @recourse_parent.is_a?(model)

      instance_variable_set "@#{model.model_name.singular}", @recourse_parent
    end
  end
end
